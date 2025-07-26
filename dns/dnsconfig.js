// @ts-check
/// <reference path="types-dnscontrol.d.ts" />

var REG_NONE = NewRegistrar("none");
var DSP_CLOUDFLARE = NewDnsProvider("cloudflare");

D(
	"lukasl.dev",
	REG_NONE,
	DnsProvider(DSP_CLOUDFLARE),

	DefaultTTL(1),

	// nodes
	A("pollux.nodes", "185.245.61.227"),
  AAAA("pollux.nodes", "2a13:7e80:0:b2::"),

	// github pages
	ALIAS("@", "lukasl-dev.github.io."),

	// services
	CNAME("anki", "pollux.nodes.lukasl.dev."),
	CNAME("api.stack-auth", "pollux.nodes.lukasl.dev."),
	CNAME("ascii", "sirius.nodes.lukasl.dev."),
	CNAME("auth", "sirius.nodes.lukasl.dev."),
	CNAME("cloud", "pollux.nodes.lukasl.dev."),
	CNAME("git", "pollux.nodes.lukasl.dev."),
	CNAME("mail", "pollux.nodes.lukasl.dev."),
	CNAME("notes", "lukasl-dev.github.io."),
	CNAME("proxy", "pollux.nodes.lukasl.dev."),
	CNAME("vault", "pollux.nodes.lukasl.dev."),

  // iconolatry
	CNAME("icons", "cname.vercel-dns.com."),

	// mail
	MX("@", 10, "mail.lukasl.dev."),
  TXT("@", "v=spf1 a:mail.lukasl.dev -all"),
	TXT(
		"_dmarc",
		"v=DMARC1; p=none; rua=mailto:4391ec514dd240209efa9f49a0c60f7c@dmarc-reports.cloudflare.net",
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
