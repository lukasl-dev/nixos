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

  // hosts
  A("pollux", "185.245.61.227"),
  CNAME("ida", "ida.llama-court.ts.net."),

  // pollux
  CNAME("anki", "pollux.lukasl.dev."),
  CNAME("marks", "pollux.lukasl.dev."),
  CNAME("box", "pollux.lukasl.dev."),
  CNAME("books", "pollux.lukasl.dev."),
  CNAME("blog", "pollux.lukasl.dev."),
  CNAME("cache", "pollux.lukasl.dev."),
  CNAME("call", "pollux.lukasl.dev."),
  CNAME("ci", "pollux.lukasl.dev."),
  CNAME("cloud", "pollux.lukasl.dev."),
  CNAME("files", "pollux.lukasl.dev."),
  CNAME("git", "pollux.lukasl.dev."),
  CNAME("forge", "pollux.lukasl.dev."),
  CNAME("notes", "pollux.lukasl.dev."),
  CNAME("proxy.pollux", "pollux.lukasl.dev."),
  CNAME("auth", "pollux.lukasl.dev."),
  CNAME("vault", "pollux.lukasl.dev."),
  CNAME("rss", "pollux.lukasl.dev."),
  CNAME("kitchen", "pollux.lukasl.dev."),
  CNAME("media", "pollux.lukasl.dev."),
  CNAME("metrics", "pollux.lukasl.dev."),
  CNAME("matrix", "pollux.lukasl.dev."),
  CNAME("meet", "pollux.lukasl.dev."),
  CNAME("turn", "pollux.lukasl.dev."),
  CNAME("fin", "pollux.lukasl.dev."),
  CNAME("ntfy", "pollux.lukasl.dev."),
  CNAME("pdf", "pollux.lukasl.dev."),
  CNAME("waka", "pollux.lukasl.dev."),
  CNAME("yam", "pollux.lukasl.dev."),
  CNAME("rspamd", "pollux.lukasl.dev."),

  // ida
  CNAME("proxy.ida", "ida.lukasl.dev."),
  CNAME("dns", "ida.lukasl.dev."),

  // iconolatry
  CNAME("icons", "cname.vercel-dns.com."),

  // mail
  A("mail", "185.245.61.227"),
  CNAME("autoconfig", "pollux.lukasl.dev."),
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
