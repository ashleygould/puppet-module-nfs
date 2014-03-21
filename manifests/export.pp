define nfs::export (
  $ensure  = 'present',
  $clients = 'localhost(ro)',
) {

  if $ensure != 'absent' {
    $line = "${name} ${clients}\n"

    concat::fragment{
      "${name}":
        target  => '/etc/exports',
        content => "${line}"
    }
  }
}

