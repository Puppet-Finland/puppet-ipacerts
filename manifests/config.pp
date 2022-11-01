#
# @Summary Apply certificate changes
#
class ipacerts::config {
  assert_private()

  # XXX: in progress

  # Add the CAs to ipa and apache nss databases
  # At this point we already have the files 
  # NOTE: the order is critical in your sourcehash
  ipa_cas { 'Configure the CAs':
    ensure       => 'present',
    certdir      => $ipacerts::certdir,
    sourcehash   => $ipacerts::chainhash,
    nickname     => 'subject',
  }

  /*  
  
   # Add the sertificate and the key to the nss database
   webui_cert_and_key { 'wildcard.openvpn.in':
     ensure      => 'present',
     key_source  => "${ipacerts::certdir}/${ipacerts::keyname}",
     cert_source => "${ipacerts::certdir}/${ipacerts::certname}",
     nss_pwfile  =>  "${certdir}/nss-password.txt", 
   }

  exec { "add_cert_${title}":
    path      => ['/usr/bin'],
    command   => "certutil -d ${certdir} -A -n '${nickname}' -t '${trustargs}' -a -i ${cert}",
    unless    => "certutil -d ${certdir} -L -n '${nickname}'",
    logoutput => true,
    require   => [
      Nsstools::Create[$certdir],
      Class['nsstools'],
    ],
  }
  
  exec {"generate_pkcs12_${title}":
    command   => "/usr/bin/openssl pkcs12 -export -in ${cert} -inkey ${key} -password 'file:${certdir}/nss-password.txt' -out '${certdir}/${pkcs12_name}' -name '${nickname}'",
    creates   => "${certdir}/${pkcs12_name}",
    subscribe => File["${certdir}/nss-password.txt"],
    require   => [
      Nsstools::Create[$certdir],
      Class['nsstools'],
    ],
  }

  exec { "add_pkcs12_${title}":
    path      => ['/usr/bin'],
    command   => "pk12util -d ${certdir} -i ${certdir}/${pkcs12_name} -w ${certdir}/nss-password.txt -k ${certdir}/nss-password.txt",
    unless    => "certutil -d ${certdir} -L -n '${nickname}'",
    logoutput => true,
    require   => [
      Exec["generate_pkcs12_${title}"],
      Nsstools::Create[$certdir],
      Class['nsstools'],
    ],
  }

  file_line { 'Ensure cert nickname':
    path    => '/etc/httpd/conf.d/nss.conf',
    replace => true,
    line    => 'NSSNickname wildcard.openvpn.in',
    match   => '^NSSNickname.*$',
    notify  => Service['httpd'],
  }
 */
}
