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
	CNAME("notes", "lukasl-dev.github.io."),
	CNAME("proxy", "pollux.planets.lukasl.dev."),
	CNAME("vault", "pollux.planets.lukasl.dev."),
	CNAME("rss", "pollux.planets.lukasl.dev."),
	CNAME("kitchen", "pollux.planets.lukasl.dev."),
	CNAME("media", "pollux.planets.lukasl.dev."),
	CNAME("metrics", "pollux.planets.lukasl.dev."),

	// iconolatry
	CNAME("icons", "cname.vercel-dns.com."),

	// mail
	A("mail", "185.245.61.227"),
	MX("@", 10, "mail.lukasl.dev."),
	TXT("@", "v=spf1 mx -all"),

	// social auth
	TXT("_atproto", "did=did:plc:hj7h5xqaqhtlinjcz4q2dclk"),
	TXT("_discord", "dh=a03d403086eab384eb683b58c4360507b7f83238"),

	// -- TXT --
	TXT(
		"@",
		"google-site-verification=SUszN4qahDNys9qK5s1jezKTNRva5rhfoBRbSkVoo3U",
	),
);
