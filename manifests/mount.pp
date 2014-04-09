define nfs::mount (
  $ensure   = 'mounted',
  $server,
  $share,
  $fstype   = 'nfs4',
  $atboot   = true,
  $options  = undef,
  $remounts = undef,
  $dump     = undef,
  $pass     = undef,
) {

  $mountpoint        = $name
  $ensure_mountpoint = $ensure ? {
    'absent' => $ensure,
    default  => 'present',
  }
  nfs::mkdir_p { $mountpoint:
    ensure => $ensure_mountpoint,
  }

  mount { $mountpoint:
    ensure   => $ensure,
    device   => "${server}:${share}",
    fstype   => $fstype,
    atboot   => $atboot,
    options  => $options,
    remounts => $remounts,
    dump     => $dump,
    pass     => $pass,
    require  => Nfs::Mkdir_p[$mountpoint],
  }

}
