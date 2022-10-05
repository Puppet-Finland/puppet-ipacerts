#
# @Summary Ensure the private key and server cert are in place
#
class ipacerts::install_key_and_cert {
  assert_private()
  
  file { "Server cert and key":
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
