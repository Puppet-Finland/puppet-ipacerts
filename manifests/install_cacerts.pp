#
# @Summary Ensure all certificates are in place
#
class ipacerts::install_cacerts {
  assert_private()

  $targetbundle="${ipacerts::certdir}/ca-bundle.pem"

  # create a the cert and files bundle then in the right order
  concat { $targetbundle:
    ensure  => present,
    content => '\n'
    require => Exec["Ensure ${ipacerts::certdir} exists"]
  }

  $ipacerts::chainhash.keys.sort.each | $key | {
    unless $ipacerts::chainhash[$key] =~ Stdlib::Filesource {
      fail(sprintf('This value cannot be a source of a file resource: %s', $ipacerts::chainhash[$key]))
    }
    $filename=$ipacerts::chainhash[$key].split(/\//)[-1]
    file { "${ipacerts::certdir}/${filename}":
      ensure => 'present',
      source => $ipacerts::chainhash[$key],
    }
    concat::fragment { "{$filename}-{$key}":
      target => $targetbundle,
      source => "${ipacerts::certdir}/${filename}",
      order  => $key,
    }
  }
}
