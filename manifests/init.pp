#
# @summary Manage 3rd party certificates in FreeIPA
#
# @example
# class {'::ipacerts':
#    chainhash                  => $chainhash,
#    admin_password             => $admin_password,
#    ipa_domain                 => $ipa_domain,
#    private_key_source         => $private_key_source,
#    server_crt_source          => $server_crt_source,
#    cert_nickname              => $cert_nickname,
#  }
#
# @param chainhash
#   A hash with numerically sorted keys of 
#   valid file uris to retrieve 
#   CA certificates in correct order
#
#   example:
# 
#   $chainhash = {
#     '1' => 'http://path/cert3.crt',
#     '2' => 'puppet:///files/cert2.crt',
#     '3' => 'file:///path/cert1.crt'
#   }
#
# @param trustargs
#  The trust attributes of the CA certificates.
#  Default is 'CT,C,C'
#
# @param admin_password
#   IPA admin password. 
#
# @param ipa_domain
#   IPA domain.  
#
# @param private_key_source
#   Source of the Web UI private key.
#
# @param server_crt_source
#   Source of the Web UI certificate.
#
# @param include_openssl
#   include openssl.
#   Default is false.
#
# @certname 
#   Name for the NSS certificate file.
#   Default is cert.pem.
#
# @keyname
#   Name for the NSS private key file.
#   Default is key.pem.
#
# @param bundlename
#   Name for the CA certificate bundle.
#   Default is ca-bundle.pem.
#
# @param cert_nickname
#   Nickname for the NSS certificate.
#
# @param mod_nss_dir
#  The NSS db directory.   
#  Default is '/etc/httpd/alias'.
#
# @param ipa_ca_present
#   Ensure CA certificates. 
#   Default is 'present'
#
# @param webui_cert_and_key_present
#   Ensure certificate and private key for the WebUI.
#   Default is 'present'.
#
# @param ca_force_absent
#   Force removal of CA certs when both webui_cert_and_key_present
#   and ipa_ca_present are set to absent.
#   First set webui_cert_and_key_present absent, then also set ipa_ca_present
#   absent AND ca_force_absent. This is stupid, I know.
class ipacerts (
  Hash $chainhash,
  Stdlib::Absolutepath $certdir,
  String $trustargs,
  String $admin_password,
  Stdlib::Fqdn $ipa_domain,
  Stdlib::Filesource $private_key_source,
  Stdlib::Filesource $server_crt_source,
  Boolean $include_openssl,
  String $certname,
  String $keyname,
  String $bundlename,
  String $cert_nickname,
  Stdlib::Absolutepath $mod_nss_dir,
  String $ipa_ca_present,
  String $webui_cert_and_key_present,
  Boolean $ca_force_absent,
) {

  contain 'ipacerts::initialize'
  contain 'ipacerts::install'
  contain 'ipacerts::config'

  Class['ipacerts::initialize']
  -> Class['ipacerts::install']
  ~> Class['ipacerts::config']
}
