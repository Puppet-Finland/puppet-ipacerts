#
# @summary Initialize 
#
class ipacerts::initialize {

  unless $facts['os']['family'] == 'RedHat' {
    fail("Unsupported osfamily: ${facts['os']['family']}, only osfamily RedHat is supported")
  }

  unless $facts['os']['release']['major'] == '7' {
    fail("Unsupported release: ${facts['os']['release']['major']}, only release 7 is supported")
  }

  if $ipacerts::include_openssl {
    include ::openssl
  }

  # ensure krb domain is in uppercase
  $_ipa_domain=$ipacerts::ipa_domain.upcase
  $get_ticket=Sensitive.new("/bin/echo ${ipacerts::admin_password} | /bin/kinit admin@${_ipa_domain}")

  exec { 'krb_ticket':
    command   => $get_ticket,
    unless    => '/bin/klist -s',
    logoutput => false,
    provider  => 'shell',
  }

  exec { "Ensure ${ipacerts::certdir} exists":
    command => "/usr/bin/mkdir -p ${ipacerts::certdir}",
    creates => $ipacerts::certdir,
  }
}
