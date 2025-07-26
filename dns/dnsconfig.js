// @ts-check
/// <reference path="types-dnscontrol.d.ts" />

var REG_NONE = NewRegistrar("none");
var DSP_CLOUDFLARE = NewDnsProvider("cloudflare");

// lukasl.dev
D(
	"lukasl.dev",
	REG_NONE,
	DnsProvider(DSP_CLOUDFLARE),

	DefaultTTL(1),

	// -- A --
	A("pollux.nodes", "185.245.61.227"),
	A("sirius.nodes", "75.119.143.38"),

	// -- AAAA --
	AAAA("pollux.nodes", "2a13:7e80:0:b2::"),

	// -- ALIAS --
	ALIAS("@", "lukasl-dev.github.io."),

	// -- CNAME --
	CNAME("anki", "pollux.nodes.lukasl.dev."),
	CNAME("api.stack-auth", "pollux.nodes.lukasl.dev."),
	CNAME("ascii", "sirius.nodes.lukasl.dev."),
	CNAME("auth", "sirius.nodes.lukasl.dev."),
	CNAME("cloud", "pollux.nodes.lukasl.dev."),
	CNAME("git", "pollux.nodes.lukasl.dev."),
	CNAME("icons", "cname.vercel-dns.com."),
	CNAME("links", "sirius.nodes.lukasl.dev."),
	CNAME("mail", "pollux.nodes.lukasl.dev."),
	CNAME("matrix", "pollux.nodes.lukasl.dev."),
	CNAME("n8n", "pollux.nodes.lukasl.dev."),
	CNAME("notes", "lukasl-dev.github.io."),
	CNAME("pds", "pollux.nodes.lukasl.dev."),
	CNAME("proxy", "pollux.nodes.lukasl.dev."),
	CNAME("read", "pollux.nodes.lukasl.dev."),
	CNAME("seal", "main.nodes.lukasl.dev."),
	CNAME("short", "main.nodes.lukasl.dev."),
	CNAME("vault", "pollux.nodes.lukasl.dev."),

	// -- MX --
	MX("@", 10, "mail.lukasl.dev."),

	// -- TXT --
	TXT("@", "v=spf1 a:mail.lukasl.dev -all"),
	TXT(
		"@",
		"google-site-verification=SUszN4qahDNys9qK5s1jezKTNRva5rhfoBRbSkVoo3U",
	),
	TXT("_atproto", "did=did:plc:hj7h5xqaqhtlinjcz4q2dclk"),
	TXT("_discord", "dh=a03d403086eab384eb683b58c4360507b7f83238"),
	TXT(
		"_dmarc",
		"v=DMARC1; p=none; rua=mailto:4391ec514dd240209efa9f49a0c60f7c@dmarc-reports.cloudflare.net",
	),
);
