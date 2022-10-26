#
# @Summary Validate CA certificates server cert and keys
#
class ipacerts::validate {
  assert_private()

  $validate_chain_and_cert="/bin/openssl verify -verbose -CAfile ${ipacerts::certdir}/${ipacerts::bundlename} ${ipacerts::certdir}/${ipacerts::certname}"
  $key_md5="\"$(/bin/openssl rsa -noout -modulus -in ${ipacerts::certdir}/${ipacerts::keyname} | openssl md5)\""
  $cert_md5="\"$(openssl x509 -noout -modulus -in ${ipacerts::certdir}/${ipacerts::certname} | openssl md5)\"" 
  $validate_cert_and_key="/bin/test ${key_md5} == ${cert_md5}"

  exec { 'Validate chain and certificate':
    command     => $validate_chain_and_cert,
    #subscribe   => [
    #  File["${ipacerts::certdir}/${ipacerts::bundlename}"],
    #  File["${ipacerts::certdir}/${ipacerts::certname}"],
    #],
    refreshonly => true,
  }

  exec { 'Validate key and certificate':
    command     => $validate_cert_and_key,
    #subscribe   => [
    #  File["${ipacerts::certdir}/${ipacerts::certname}"],
    #  File["${ipacerts::certdir}/${ipacerts::keyname}"],
    #],
    refreshonly => true,
  }
}
