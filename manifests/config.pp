#
# @Summary Apply certificate changes
#
class ipacerts::config {
  assert_private()

  # Add the CAs to ipa and apache nss databases
  # At this point we already have the files 
  # NOTE: the order is critical in your sourcehash
  $ipacerts::chainhash.keys.each | $key | {
    $filename=$ipacerts::chainhash[$key].split(/\//)[-1]
    ipa_ca { "${ipacerts::certdir}/${filename}":
      ensure    => $ipacerts::ipa_ca_present,
      order     => $key,
      filepath  => "${ipacerts::certdir}/${filename}",
      trustargs => $ipacerts::trustargs,
      require   => Service['ipa'],
      notify    => Exec['ipa certupdate'],
    }
  }

  exec { 'ipa certupdate':
    command     => '/sbin/ipa-certupdate -v',
    refreshonly => true,
  }

  webui_cert_and_key { $ipacerts::cert_nickname:
    ensure   => $ipacerts::webui_cert_and_key_present,
    keyfile  => "${ipacerts::certdir}/${ipacerts::keyname}",
    certfile => "${ipacerts::certdir}/${ipacerts::certname}",
    dir      => $ipacerts::mod_nss_dir,
    nickname => $ipacerts::cert_nickname,
    require  => Service['ipa'],
  }

  $nickname = $ipacerts::webui_cert_and_key_present ? {
    'present' => $ipacerts::cert_nickname,
    'absent'  => 'Server-Cert',
    default   => 'Server-Cert',
  }
  file_line { 'Ensure cert nickname':
    path    => '/etc/httpd/conf.d/nss.conf',
    replace => true,
    line    => "NSSNickname ${nickname}",
    match   => '^NSSNickname.*$',
    require =>  Webui_cert_and_key[$ipacerts::cert_nickname],
    notify  => Exec['httpd reload'],
  }

  exec { 'httpd reload':
    command     => '/bin/systemctl reload httpd',
    logoutput   => on_failure,
    refreshonly => true,
  }
}


