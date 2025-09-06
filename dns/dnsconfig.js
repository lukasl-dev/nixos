// @ts-check
/// <reference path="types-dnscontrol.d.ts" />

var REG_NONE = NewRegistrar("none");
var DSP_CLOUDFLARE = NewDnsProvider("cloudflare");

D(
	"lukasl.dev",
	REG_NONE,
	DnsProvider(DSP_CLOUDFLARE),

	DefaultTTL(1),

	// planets
	A("pollux.planets", "185.245.61.227"),
	AAAA("pollux.planets", "2a13:7e80:0:b2::"),

	// github pages
	ALIAS("@", "lukasl-dev.github.io."),

	// services
	CNAME("anki", "pollux.planets.lukasl.dev."),
	CNAME("cloud", "pollux.planets.lukasl.dev."),
	CNAME("git", "pollux.planets.lukasl.dev."),
	CNAME("ntfy", "pollux.planets.lukasl.dev."),
	CNAME("notes", "lukasl-dev.github.io."),
	CNAME("proxy", "pollux.planets.lukasl.dev."),
	CNAME("vault", "pollux.planets.lukasl.dev."),
	CNAME("rss", "pollux.planets.lukasl.dev."),
	CNAME("kitchen", "pollux.planets.lukasl.dev."),
	CNAME("media", "pollux.planets.lukasl.dev."),
	CNAME("metrics", "pollux.planets.lukasl.dev."),
	CNAME("nix", "pollux.planets.lukasl.dev."),

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
