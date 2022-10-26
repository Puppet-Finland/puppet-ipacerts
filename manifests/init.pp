#
# @summary Manage 3rd party certificates in FreeIPA
#
# @param chainhash
#  A hash with alphabetically sorted keys of 
#  valid file uris to retrieve 
#  CA certificates in correct order
#
#  example:
# 
# $chainhash = {
#  'c' => 'http://path/cert3.crt',
#  'b' => 'http://path/cert2.crt',
#  'a' => 'file:///path/cert1.crt'
# }
class ipacerts (
  Hash $chainhash,
  Stdlib::Absolutepath $certdir,
  String $trustargs,
  String $admin_password,
  Stdlib::Fqdn $ipa_domain,
  Stdlib::Filesource $private_key_source,
  Stdlib::Filesource $server_crt_source,
  Boolean $include_openssl,
  String $certname = 'cert.pem',
  String $keyname = 'key.pem',
  String $bundlename = 'ca-bundle.pem'
) {

  contain 'ipacerts::initialize'
  contain 'ipacerts::install_cacerts'
  contain 'ipacerts::install_cert_and_key'
  contain 'ipacerts::validate'
  contain 'ipacerts::config'

  Class['ipacerts::initialize']
  -> Class['ipacerts::install_cacerts']
  -> Class['ipacerts::install_cert_and_key']
  -> Class['ipacerts::validate']
  -> Class['ipacerts::config']

  Class['ipacerts::install_cacerts']~>Class['ipacerts::validate']
  Class['ipacerts::install_cert_and_key']~>Class['ipacerts::validate']
}
