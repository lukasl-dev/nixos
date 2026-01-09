// @ts-check
/// <reference path="types-dnscontrol.d.ts" />

var REG_NONE = NewRegistrar("none");
var DSP_CLOUDFLARE = NewDnsProvider("cloudflare");

D(
  "lukasl.dev",
  REG_NONE,
  DnsProvider(DSP_CLOUDFLARE),

  DefaultTTL(1),

  A("@", "185.245.61.227"),

  // planets
  A("pollux.planets", "185.245.61.227"),

  // services
  CNAME("anki", "pollux.planets.lukasl.dev."),
  CNAME("box", "pollux.planets.lukasl.dev."),
  CNAME("books", "pollux.planets.lukasl.dev."),
  CNAME("blog", "pollux.planets.lukasl.dev."),
  CNAME("cache", "pollux.planets.lukasl.dev."),
  CNAME("call", "pollux.planets.lukasl.dev."),
  CNAME("ci", "pollux.planets.lukasl.dev."),
  CNAME("cloud", "pollux.planets.lukasl.dev."),
  CNAME("files", "pollux.planets.lukasl.dev."),
  CNAME("git", "pollux.planets.lukasl.dev."),
  CNAME("forge", "pollux.planets.lukasl.dev."),
  CNAME("notes", "pollux.planets.lukasl.dev."),
  CNAME("proxy", "pollux.planets.lukasl.dev."),
  CNAME("auth", "pollux.planets.lukasl.dev."),
  CNAME("vault", "pollux.planets.lukasl.dev."),
  CNAME("rss", "pollux.planets.lukasl.dev."),
  CNAME("kitchen", "pollux.planets.lukasl.dev."),
  CNAME("media", "pollux.planets.lukasl.dev."),
  CNAME("metrics", "pollux.planets.lukasl.dev."),
  CNAME("matrix", "pollux.planets.lukasl.dev."),
  CNAME("meet", "pollux.planets.lukasl.dev."),
  CNAME("turn", "pollux.planets.lukasl.dev."),
  CNAME("fin", "pollux.planets.lukasl.dev."),
  CNAME("ntfy", "pollux.planets.lukasl.dev."),
  CNAME("waka", "pollux.planets.lukasl.dev."),
  CNAME("yam", "pollux.planets.lukasl.dev."),

  // iconolatry
  CNAME("icons", "cname.vercel-dns.com."),

  // mail
  A("mail", "185.245.61.227"),
  CNAME("autoconfig", "pollux.planets.lukasl.dev."),
  MX("@", 10, "mail.lukasl.dev."),
  TXT("@", "v=spf1 mx -all"),
  TXT(
    "default._domainkey",
    "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzXZ9KSNwZeQltqCdiXJpK9/UWrOPaleqIP2sHR/IquUb/h1/9KNfiJBtX14KXbCugf4+Ae/d42Jlxt4138cbwKjjoxSSPpHZyNKN9MD+GpYX17Ytx+zr5B7zQDGjg7vqH/+QmtdDho/VjpaX7HYZS6ACINgMCDs57Y8K2KTn7v+LVxecauPTvdgHUCW559aKXX9F5pqmFHIvOgMSX2i116+o+CrxTOo+g3NeMKQmct7Jh+h66hSK5ocazIOV6FEttODaZ0zCqqx+lBJRTzLWyZ0I8iAiSrnj+jfcguBpRO6FMswfyHxKu9DgPSfnoMk6nGgFm9sD6YIZ2erPRy7FFwIDAQAB",
  ),
  TXT(
    "_dmarc",
    "v=DMARC1; p=quarantine; rua=mailto:dmarc@lukasl.dev; ruf=mailto:dmarc@lukasl.dev; fo=1; adkim=s; aspf=s; pct=100",
  ),

  // social auth
  TXT("_atproto", "did=did:plc:hj7h5xqaqhtlinjcz4q2dclk"),
  TXT("_discord", "dh=a03d403086eab384eb683b58c4360507b7f83238"),

  // -- TXT --
  TXT(
    "@",
    "google-site-verification=SUszN4qahDNys9qK5s1jezKTNRva5rhfoBRbSkVoo3U",
  ),
);

D(
  "onyx.md",
  REG_NONE,
  DnsProvider(DSP_CLOUDFLARE),

  DefaultTTL(1),

  A("@", "216.198.79.1"),
  CNAME("www", "609cdebc2adcc25c.vercel-dns-017.com."),

  TXT("_discord", "dh=a093e62cdc46e107e1f3be45b38db8ad9bafcaf4"),
);
