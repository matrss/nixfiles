terraform {
  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

data "sops_file" "secrets" {
  source_file = "secrets/tofu/secrets.yaml"
}

provider "cloudflare" {
  api_token = data.sops_file.secrets.data["cloudflare.token"]
}


resource "cloudflare_account" "main" {
  name = "Matthias.risze@gmail.com's Account"
}


resource "cloudflare_zone" "_0px_xyz" {
  account_id = cloudflare_account.main.id
  zone       = "0px.xyz"
  plan       = "free"
}

resource "cloudflare_record" "_mx1_0px_xyz" {
  zone_id  = cloudflare_zone._0px_xyz.id
  type     = "MX"
  name     = "@"
  content  = "mxext1.mailbox.org"
  priority = 10
}

resource "cloudflare_record" "_mx2_0px_xyz" {
  zone_id  = cloudflare_zone._0px_xyz.id
  type     = "MX"
  name     = "@"
  content  = "mxext2.mailbox.org"
  priority = 10
}

resource "cloudflare_record" "_mx3_0px_xyz" {
  zone_id  = cloudflare_zone._0px_xyz.id
  type     = "MX"
  name     = "@"
  content  = "mxext3.mailbox.org"
  priority = 20
}

resource "cloudflare_record" "_mailbox_org_key_0px_xyz" {
  zone_id = cloudflare_zone._0px_xyz.id
  type    = "TXT"
  name    = "af076b4bcc5f8b23a433451430882449a50da3cb"
  content = "3b7424523e47d460a9b8edc2d2723118fedc0d70"
}

resource "cloudflare_record" "_dmarc_0px_xyz" {
  zone_id = cloudflare_zone._0px_xyz.id
  type    = "TXT"
  name    = "_dmarc"
  content = "v=DMARC1; p=none; rua=mailto:postmaster@0px.xyz"
}

resource "cloudflare_record" "_1_domainkey_0px_xyz" {
  zone_id = cloudflare_zone._0px_xyz.id
  type    = "CNAME"
  name    = "mbo0001._domainkey"
  content = "mbo0001._domainkey.mailbox.org"
}

resource "cloudflare_record" "_2_domainkey_0px_xyz" {
  zone_id = cloudflare_zone._0px_xyz.id
  type    = "CNAME"
  name    = "mbo0002._domainkey"
  content = "mbo0002._domainkey.mailbox.org"
}

resource "cloudflare_record" "_3_domainkey_0px_xyz" {
  zone_id = cloudflare_zone._0px_xyz.id
  type    = "CNAME"
  name    = "mbo0003._domainkey"
  content = "mbo0003._domainkey.mailbox.org"
}

resource "cloudflare_record" "_4_domainkey_0px_xyz" {
  zone_id = cloudflare_zone._0px_xyz.id
  type    = "CNAME"
  name    = "mbo0004._domainkey"
  content = "mbo0004._domainkey.mailbox.org"
}

resource "cloudflare_record" "_spf_0px_xyz" {
  zone_id = cloudflare_zone._0px_xyz.id
  type    = "TXT"
  name    = "@"
  content = "v=spf1 include:mailbox.org ~all"
}

resource "cloudflare_record" "hub_0px_xyz" {
  zone_id = cloudflare_zone._0px_xyz.id
  type    = "CNAME"
  name    = "hub"
  content = "nx73356.your-storageshare.de"
}

resource "cloudflare_record" "services_mpanra_m_0px_xyz" {
  zone_id  = cloudflare_zone._0px_xyz.id
  for_each = toset(["cloud", "home", "idm", "media", "nix-cache", "paperless", "wiki"])
  type     = "CNAME"
  name     = each.key
  content  = "mpanra.m.0px.xyz"
}

resource "cloudflare_record" "hazuno_m_0px_xyz_A" {
  zone_id = cloudflare_zone._0px_xyz.id
  type    = "A"
  name    = "hazuno.m"
  content = "130.61.249.195"
}

resource "cloudflare_record" "services_hazuno_m_0px_xyz" {
  zone_id  = cloudflare_zone._0px_xyz.id
  for_each = toset(["dns", "status"])
  type     = "CNAME"
  name     = each.key
  content  = "hazuno.m.0px.xyz"
}

resource "cloudflare_record" "hazuno_m_0px_xyz_AAAA" {
  zone_id = cloudflare_zone._0px_xyz.id
  type    = "AAAA"
  name    = "hazuno.m"
  content = "2603:c020:800b:fd00:2b10:e461:ff1e:d3e9"
}

resource "cloudflare_zone" "matrss_de" {
  account_id = cloudflare_account.main.id
  zone       = "matrss.de"
  plan       = "free"
}

resource "cloudflare_record" "_dmarc_matrss_de" {
  zone_id = cloudflare_zone.matrss_de.id
  type    = "TXT"
  name    = "_dmarc"
  content = "v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s;"
}

resource "cloudflare_record" "_domainkey_matrss_de" {
  zone_id = cloudflare_zone.matrss_de.id
  type    = "TXT"
  name    = "*._domainkey"
  content = "v=DKIM1; p="
}

resource "cloudflare_record" "_spf_matrss_de" {
  zone_id = cloudflare_zone.matrss_de.id
  type    = "TXT"
  name    = "@"
  content = "v=spf1 -all"
}


resource "cloudflare_zone" "matrss_xyz" {
  account_id = cloudflare_account.main.id
  zone       = "matrss.xyz"
  plan       = "free"
}

resource "cloudflare_record" "_mx1_matrss_xyz" {
  zone_id  = cloudflare_zone.matrss_xyz.id
  type     = "MX"
  name     = "@"
  content  = "mxext1.mailbox.org"
  priority = 10
}

resource "cloudflare_record" "_mx2_matrss_xyz" {
  zone_id  = cloudflare_zone.matrss_xyz.id
  type     = "MX"
  name     = "@"
  content  = "mxext2.mailbox.org"
  priority = 10
}

resource "cloudflare_record" "_mx3_matrss_xyz" {
  zone_id  = cloudflare_zone.matrss_xyz.id
  type     = "MX"
  name     = "@"
  content  = "mxext3.mailbox.org"
  priority = 20
}

resource "cloudflare_record" "_mailbox_org_key_matrss_xyz" {
  zone_id = cloudflare_zone.matrss_xyz.id
  type    = "TXT"
  name    = "af076b4bcc5f8b23a433451430882449a50da3cb"
  content = "d7dee9611edce34be64490a5cc1a69cd261f518a"
}

resource "cloudflare_record" "_dmarc_matrss_xyz" {
  zone_id = cloudflare_zone.matrss_xyz.id
  type    = "TXT"
  name    = "_dmarc"
  content = "v=DMARC1; p=none; rua=mailto:postmaster@matrss.xyz"
}

resource "cloudflare_record" "_1_domainkey_matrss_xyz" {
  zone_id = cloudflare_zone.matrss_xyz.id
  type    = "CNAME"
  name    = "mbo0001._domainkey"
  content = "mbo0001._domainkey.mailbox.org"
}

resource "cloudflare_record" "_2_domainkey_matrss_xyz" {
  zone_id = cloudflare_zone.matrss_xyz.id
  type    = "CNAME"
  name    = "mbo0002._domainkey"
  content = "mbo0002._domainkey.mailbox.org"
}

resource "cloudflare_record" "_3_domainkey_matrss_xyz" {
  zone_id = cloudflare_zone.matrss_xyz.id
  type    = "CNAME"
  name    = "mbo0003._domainkey"
  content = "mbo0003._domainkey.mailbox.org"
}

resource "cloudflare_record" "_4_domainkey_matrss_xyz" {
  zone_id = cloudflare_zone.matrss_xyz.id
  type    = "CNAME"
  name    = "mbo0004._domainkey"
  content = "mbo0004._domainkey.mailbox.org"
}

resource "cloudflare_record" "_spf_matrss_xyz" {
  zone_id = cloudflare_zone.matrss_xyz.id
  type    = "TXT"
  name    = "@"
  content = "v=spf1 include:mailbox.org ~all"
}
