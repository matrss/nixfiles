final: prev: {
  filebot = prev.filebot.overrideAttrs (old: {
    src = builtins.fetchurl {
      url = "https://get.filebot.net/filebot/FileBot_${old.version}/FileBot_${old.version}-portable.tar.xz";
      sha256 = "sha256-T+y8k757/qFCVOCc/SNc7a+KmyscPlowubNQYzMr8jY=";
    };
  });
}
