#
# @Summary Ensure all CA certificates are in place
#
class ipacerts::install_cacerts {
  assert_private()
  
  $targetbundle="${ipacerts::certdir}/ca-bundle.pem"

  ca_chain { $targetbundle:
    ensure => 'present',
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
}
