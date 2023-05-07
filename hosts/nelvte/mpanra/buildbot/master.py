import os
import json
import datetime
import multiprocessing
import uuid
from pathlib import Path
from buildbot.plugins import *
from buildbot.process import buildstep, logobserver
from buildbot.steps.trigger import Trigger
from twisted.internet import defer
from buildbot.process.results import ALL_RESULTS, statusToString
from buildbot.process.properties import Properties
from typing import Any, Generator


# {{{
# src: https://github.com/Mic92/dotfiles/blob/2e7aa81eb14af118f5c6c1c91111db9775b6090a/nixos/eve/modules/buildbot/buildbot_nix.py
class BuildTrigger(Trigger):
    """
    Dynamic trigger that creates a build for every attribute.
    """

    def __init__(self, scheduler: str, jobs: list[dict[str, str]], **kwargs):
        if "name" not in kwargs:
            kwargs["name"] = "trigger"
        self.jobs = jobs
        self.config = None
        Trigger.__init__(
            self,
            waitForFinish=True,
            schedulerNames=[scheduler],
            haltOnFailure=True,
            flunkOnFailure=True,
            sourceStamps=[],
            alwaysUseLatest=False,
            updateSourceStamp=False,
            **kwargs,
        )

    def createTriggerProperties(self, props):
        return props

    def getSchedulersAndProperties(self):
        build_props = self.build.getProperties()
        repo_name = None
        # repo_name = build_props.getProperty(
        #     "github.base.repo.full_name",
        #     build_props.getProperty("github.repository.full_name"),
        # )

        # parent_buildid

        sch = self.schedulerNames[0]
        triggered_schedulers = []
        for job in self.jobs:
            attr = job.get("attr", "eval-error")
            name = attr
            if repo_name is not None:
                name = f"{repo_name}: {name}"
            drv_path = job.get("drvPath")
            error = job.get("error")
            out_path = job.get("outputs", {}).get("out")

            build_props.setProperty(f"{attr}-out_path", out_path, "nix-eval")
            build_props.setProperty(f"{attr}-drv_path", drv_path, "nix-eval")

            props = Properties()
            props.setProperty("virtual_builder_name", name, "nix-eval")
            props.setProperty("virtual_builder_tags", "", "nix-eval")
            props.setProperty("attr", attr, "nix-eval")
            props.setProperty("drv_path", drv_path, "nix-eval")
            props.setProperty("out_path", out_path, "nix-eval")
            # we use this to identify builds when running a retry
            props.setProperty("build_uuid", str(uuid.uuid4()), "nix-eval")
            props.setProperty("error", error, "nix-eval")
            triggered_schedulers.append((sch, props))
        return triggered_schedulers

    def getCurrentSummary(self):
        """
        The original build trigger will the generic builder name `nix-build` in this case, which is not helpful
        """
        if not self.triggeredNames:
            return {"step": "running"}
        summary = []
        if self._result_list:
            for status in ALL_RESULTS:
                count = self._result_list.count(status)
                if count:
                    summary.append(
                        f"{self._result_list.count(status)} {statusToString(status, count)}"
                    )
        return {"step": f"({', '.join(summary)})"}


class NixEvalCommand(buildstep.ShellMixin, steps.BuildStep):
    """
    Parses the output of `nix-eval-jobs` and triggers a `nix-build` build for
    every attribute.
    """

    def __init__(self, **kwargs):
        kwargs = self.setupShellMixin(kwargs)
        super().__init__(**kwargs)
        self.observer = logobserver.BufferLogObserver()
        self.addLogObserver("stdio", self.observer)

    @defer.inlineCallbacks
    def run(self) -> Generator[Any, object, Any]:
        # run nix-instanstiate to generate the dict of stages
        cmd = yield self.makeRemoteShellCommand()
        yield self.runCommand(cmd)

        # if the command passes extract the list of stages
        result = cmd.results()
        if result == util.SUCCESS:
            # create a ShellCommand for each stage and add them to the build
            jobs = []

            for line in self.observer.getStdout().split("\n"):
                if line != "":
                    job = json.loads(line)
                    jobs.append(job)
            self.build.addStepsAfterCurrentStep(
                [BuildTrigger(scheduler="nix-build", name="nix-build", jobs=jobs)]
            )

        return result


def nix_eval_config(workernames):
    factory = util.BuildFactory()
    factory.addStep(steps.GitLab(
        repourl=util.Property("repository"),
        mode="full",
        method="clobber",
        shallow=True,
        # Transform is necessary since the secrets provider seems to strip newlines too much.
        # Should be fixed in buildbot 3.8.0
        sshPrivateKey=util.Transform(lambda x: x + "\n", util.Secret("ssh-private-key")),
        sshHostKey="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf",
        haltOnFailure=True,
    ))
    factory.addStep(
        NixEvalCommand(
            env={},
            name="Eval flake",
            command=[
                "nix",
                "run",
                "--option",
                "accept-flake-config",
                "true",
                "--option",
                "extra-experimental-features",
                "nix-command",
                "--option",
                "extra-experimental-features",
                "flakes",
                "github:nix-community/nix-eval-jobs",
                "--",
                "--workers",
                multiprocessing.cpu_count(),
                "--option",
                "accept-flake-config",
                "true",
                "--option",
                "extra-experimental-features",
                "flakes",
                "--gc-roots-dir",
                # FIXME: don't hardcode this
                "/var/lib/buildbot/gcroot",
                "--flake",
                ".#hydraJobs",
            ],
            haltOnFailure=True,
        )
    )
    return util.BuilderConfig(
        name="nix-eval",
        workernames=workernames,
        properties=dict(virtual_builder_name="nix-eval"),
        factory=factory,
    )


class NixBuildCommand(buildstep.ShellMixin, steps.BuildStep):
    """
    Builds a nix derivation if evaluation was successful,
    otherwise this shows the evaluation error.
    """

    def __init__(self, **kwargs):
        kwargs = self.setupShellMixin(kwargs)
        super().__init__(**kwargs)
        self.observer = logobserver.BufferLogObserver()
        self.addLogObserver("stdio", self.observer)

    @defer.inlineCallbacks
    def run(self) -> Generator[Any, object, Any]:
        error = self.getProperty("error")
        if error is not None:
            attr = self.getProperty("attr")
            # show eval error
            self.build.results = util.FAILURE
            log = yield self.addLog("nix_error")
            log.addStderr(f"{attr} failed to evaluate:\n{error}")
            return util.FAILURE

        # run `nix build`
        cmd = yield self.makeRemoteShellCommand()
        yield self.runCommand(cmd)

        res = cmd.results()
        return res


def nix_build_config(workernames):
    factory = util.BuildFactory()
    factory.addStep(
        NixBuildCommand(
            env={},
            name="Build flake attr",
            command=[
                "nix",
                "build",
                "-L",
                "--option",
                "keep-going",
                "true",
                "--option",
                "extra-experimental-features",
                "nix-command",
                "--option",
                "extra-experimental-features",
                "flakes",
                "--out-link",
                util.Interpolate("result-%(prop:attr)s"),
                util.Property("drv_path"),
            ],
            haltOnFailure=True,
        )
    )
    return util.BuilderConfig(
        name="nix-build",
        workernames=workernames,
        properties=[],
        collapseRequests=False,
        env={},
        factory=factory,
    )
# }}}


def build_config():
    credentials_dir = Path(os.environ["CREDENTIALS_DIRECTORY"])

    c = {}
    c["buildbotNetUsageData"] = None

    c["secretsProviders"] = [secrets.SecretInAFile(dirname=credentials_dir)]

    # configure a janitor which will delete all logs older than one month, and will run on sundays at noon
    c["configurators"] = [
        util.JanitorConfigurator(logHorizon=datetime.timedelta(weeks=4), hour=12, dayOfWeek=6)
    ]

    c["schedulers"] = [
        # build all pushes to and merge requests targeting the main branch
        schedulers.SingleBranchScheduler(
            name="main",
            builderNames=["nix-eval"],
            change_filter=util.ChangeFilter(
                branch="main",
                project="nixfiles",
                category=["push", "merge_request"]
            ),
        ),
        # this is triggered from `nix-eval`
        schedulers.Triggerable(
            name="nix-build",
            builderNames=["nix-build"],
        ),
        # allow to manually trigger a nix-build
        schedulers.ForceScheduler(name="force", builderNames=["nix-eval"]),
    ]

    c["services"] = []

    c["workers"] = [
        worker.LocalWorker("bot-1"),
    ]

    c["builders"] = [
        nix_eval_config(["bot-1"]),
        nix_build_config(["bot-1"]),
    ]

    users = json.loads((credentials_dir / "users").read_text())

    c["www"] = {
        "port": 8010,
        "auth": util.UserPasswordAuth(users),
        "authz": util.Authz(
            roleMatchers=[
                util.RolesFromUsername(roles=["admin"], usernames=["matrss"]),
            ],
            allowRules=[
                util.AnyControlEndpointMatcher(role="admin"),
            ],
        ),
        "plugins": dict(waterfall_view={}, console_view={}, grid_view={}),
        "change_hook_dialects": dict(
            gitlab=dict(
                secret=util.Secret("gitlab-hook-secret"),
            ),
        ),
    }

    c["db"] = {"db_url": "sqlite:///state.sqlite"}

    c["buildbotURL"] = "https://buildbot.0px.xyz/"

    return c


BuildmasterConfig = build_config()
