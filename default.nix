with import <nixpkgs> { };
with perlPackages;


buildPerlPackage rec {
  name = "rt-${version}";
  version = "0.0.1";

  shellHook = ''
    # one history per project, isn't that cool?
    export HISTFILE="`pwd`/.zsh_history"
  '';

  goPackagePath = "github.com/nixcloud/nixcloud";

  buildInputs = [ perl perlPackages.GraphViz perlPackages.LWP perlPackages.NetCIDR perlPackages.Plack perlPackages.HTMLMason perlPackages.IPCRun3 perlPackages.DBI perlPackages.XMLRegExp perlPackages.TermReadKey perlPackages.JSON perlPackages.UNIVERSALrequire perlPackages.HTMLTemplate perlPackages.TextTemplate perlPackages.TextWikiFormat perlPackages.DBDmysql perlPackages.HTMLScrubber perlPackages.StringShellQuote perlPackages.MozillaCA perlPackages.FCGI perlPackages.TreeSimple perlPackages.Encode perlPackages.LogDispatch perlPackages.CryptSSLeay perlPackages.LWPProtocolHttps perlPackages.FileWhich perlPackages.MIMETypes perlPackages.CryptEksblowfish perlPackages.MailTools perlPackages.NetCIDR perlPackages.NetIP perlPackages.EmailAddress perlPackages.CryptX509 perlPackages.FCGI-ProcManager perlPackages.Data-ICal perlPackages.Convert-Color perlPackages.DateManip perlPackages.Regexp-Common-net-CIDR perlPackages.CGI-PSGI perlPackages.CGI-Emulate-PSGI perlPackages.LocaleMaketext perlPackages.DevelGlobalDestruction perlPackages.MIMEtools perlPackages.CSSSquish perlPackages.ApacheSession perlPackages.LocaleMaketextFuzzy perlPackages.DateTime perlPackages.ModuleRefresh perlPackages.DBIxSearchBuilder perlPackages.HTMLQuoted perlPackages.TextQuoted perlPackages.XMLRSS perlPackages.DateTimeFormatNatural perlPackages.ModuleVersionsReport perlPackages.ModuleVersionsReport perlPackages.RoleBasic perlPackages.DateExtract perlPackages.HTMLFormTWithLaT perlPackages.HTMLRewriteAttributes perlPackages.RegexpIPv6 perlPackages.DataGUID perlPackages.TextWrapper perlPackages.SymbolGlobalName perlPackages.TextPasswordPronounceable perlPackages.EmailAddressList perlPackages.HTMLMasonPSGIHandler perlPackages.LocaleMaketextLexicon perlPackages.TimeParseDate perlPackages.Starlet autoconf gnumake perlPackages.DevelTrace perlPackages.PlackAppWebSocket perlPackages.Twiggy perlPackages.DistZilla perlPackages.DistZillaMintingProfileRTx perlPackages.TermUI     perlPackages.namespaceautoclean perlPackages.MooseXRoleParameterized perlPackages.MooseXNonMoose perlPackages.ClassMethodModifiers perlPackages.Moose perlPackages.Plack perlPackages.JSON perlPackages.ModulePath  perlPackages.PodPOM perlPackages.WebMachine perlPackages.PlackMiddlewareRequestHeaders perlPackages.PlackMiddlewareReverseProxyPath perlPackages.WebMachine perlPackages.WebSimple perlPackages.Redis perlPackages.AnyEventRedis Redis perlPackages.AnyEventRedisRipeRedis Mojolicious MojoRedis2 MojoliciousPluginAuthentication redis];
}

