#
# @Summary Ensure all certificates and the private key are place
#
class ipacerts::install {
  assert_private()

  $targetbundle="${ipacerts::certdir}/${ipacerts::bundlename}"
  $keyfile="${ipacerts::certdir}/${ipacerts::keyname}"
  $certfile="${ipacerts::certdir}/${ipacerts::certname}"

  ca_chain { $targetbundle:
    ensure     => 'present',
    sourcehash => $ipacerts::chainhash,
  }

  $ipacerts::chainhash.keys.each | $key | {
    unless $ipacerts::chainhash[$key] =~ Stdlib::Filesource {
      fail(sprintf('This value cannot be a source of a file resource: %s', $ipacerts::chainhash[$key]))
    }
    $filename=$ipacerts::chainhash[$key].split(/\//)[-1]
    file { "${ipacerts::certdir}/${filename}":
      ensure => 'present',
      source => $ipacerts::chainhash[$key],
    }
  }

  file {
    default:
      owner => 'root',
      group => 'root',
      mode  => '0400',
      ;
    $keyfile:
      source => $ipacerts::private_key_source,
      ;
    $certfile:
      source => $ipacerts::server_crt_source,
      ;
  }

  $validate_chain_and_cert="/bin/openssl verify -verbose -CAfile ${targetbundle} ${certfile}"
  $key_md5="\"$(/bin/openssl rsa -noout -modulus -in ${keyfile} | /bin/openssl md5)\""
  $cert_md5="\"$(openssl x509 -noout -modulus -in ${certfile} | /bin/openssl md5)\""
  $validate_cert_and_key="/bin/test ${key_md5} == ${cert_md5}"

  exec { 'Validate chain and certificate':
    command     => $validate_chain_and_cert,
    subscribe   => [
      Ca_chain[$targetbundle],
      File[$certfile],
    ],
    refreshonly => true,
    logoutput   => on_failure,
  }

  exec { 'Validate key and certificate':
    command     => $validate_cert_and_key,
    subscribe   => [
      File[$keyfile],
      File[$certfile],
    ],
    refreshonly => true,
    logoutput   => on_failure,
  }
}
