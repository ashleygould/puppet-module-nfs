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

  $mountpoint = $name

  nfs::mkdir_p { $mountpoint: }

  mount { $mountpoint:
    ensure   => $ensure,
    device   => "${server}:/${share}",
    fstype   => $fstype,
    atboot   => $atboot,
    options  => $options,
    remounts => $remounts,
    dump     => $dump,
    pass     => $pass,
    require  => Nfs::Mkdir_p[$mountpoint],
  }

}
