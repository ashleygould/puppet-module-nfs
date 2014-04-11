# = Define: nfs::bindmount
# Creates a bind mount filesystem
#
# === Parameters:
# $name::    The resource title - the directory name of the mountpoint.
# $ensure::  Ensures creation of bind mount filesystem.  Default: 'mounted'.
# $device::  Fully qualified path to device to be mounted.  Required.
# $options:: Additional mount options to append.  Optional.
#
# === Usage:
#  nfs::bindmount { '/exports/nfs-data':
#    device => '/data',
#  }
#
define nfs::bindmount (
  $ensure  = 'mounted',
  $device  = undef,
  $options = undef,
) {
  
  $mountpoint        = $name
  $ensure_mountpoint = $ensure ? {
    'absent' => $ensure,
    default  => 'present',
  }
  nfs::mkdir_p { $mountpoint:
    ensure   => $ensure_mountpoint,
  }

  if $options {
    $real_options = "bind,${options}"
  } else {
    $real_options = 'bind'
  }
      
  if $device == undef {
    fail ("Nfs::Bindmount[${name}]: attribute 'device' is undefined")
  } else {
    validate_absolute_path($device)
  }

  mount { $mountpoint: 
    ensure  => $ensure,
    device  => $device,
    atboot  => true,
    fstype  => 'none',
    options => $real_options,
    require => Nfs::Mkdir_p[$mountpoint],
  }

}

