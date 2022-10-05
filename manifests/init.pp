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
  Stdlib::Fqdn $domain,
  Stdlib::Filesource $private_key_source,
  Stdlib::Filesource $server_crt_source,
) {

  unless $facts['os']['family'] == 'RedHat' {
    fail("Unsupported osfamily: ${facts['os']['family']}, module ${module_name} only supports osfamily Redhat")
  }

  include ::openssl

  # ensure krb domain is in upcase
  $_domain=$domain.upcase

  $keyfile="${ipacerts::certdir}/keyfile.pem"
  $certfile="${ipacerts::certdir}/certfile.pem"

  # ensure we have a ticket to do our things
  $password=Sensitive($admin_password)
  $get_ticket=Sensitive.new("/bin/echo ${passwd.unwrap} | /bin/kinit admin@${_domain}")

  exec { 'krb_ticket':
    command   => $get_ticket,
    unless    => '/bin/klist -s',
    logoutput => true,
    provider  => 'shell',
  }

  exec { "Ensure ${certdir} exists":
    command => "mkdir -p ${certdir}",
    creates => $certdir,
  }

  contain 'ipacerts::install_cacerts'
  contain 'ipacerts::install_cert_and_key'
  contain 'ipacerts::validate'
  contain 'ipacerts::config'

  Class['ipacerts::install_cacerts']
  -> Class['ipacerts::install_cert_and_key']
  -> Class['ipacerts::validate']
  -> Class['ipacerts::config']
}
