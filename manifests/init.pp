#
# @summary Manage 3rd party certificates in FreeIPA
#
# @param chainhash
#  A hash with numerically sorted keys of 
#  valid file uris to retrieve 
#  CA certificates in correct order
#
#  example:
# 
# $chainhash = {
#  '3' => 'http://path/cert3.crt',
#  '2' => 'http://path/cert2.crt',
#  '1' => 'file:///path/cert1.crt'
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
  contain 'ipacerts::install'
  contain 'ipacerts::config'

  Class['ipacerts::initialize']
  -> Class['ipacerts::install']
  -> Class['ipacerts::config']
}
