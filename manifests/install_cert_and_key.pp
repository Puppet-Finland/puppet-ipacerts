#
# @Summary Ensure the private key and server cert are in place
#
class ipacerts::install_cert_and_key {
  assert_private()

  $keyfile="${ipacerts::certdir}/keyfile.pem"
  $certfile="${ipacerts::certdir}/certfile.pem"

  file {
    default:
      owner => 'root',
      group => 'root',
      mode  => '0400',
      ;
    $keyfile:
      source => $ipacerts::keyfile,
      ;
    $certfile:
      source => $ipacerts::certfile,
      ;
  }
}
