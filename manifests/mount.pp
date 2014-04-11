# = Define: nfs::mount
#
# Configure and mount and nfs file share.
#
# === Provides:
# - create the mountpoint directory named for the resource title.
# - implement a puppet mount resource
#
# === Parameters:
# $name::	The resource title - the directory name of the mountpoint.
# $ensure::	Ensure whether to mount the fileshare.  Default: 'mounted'.
# $server::	The hostname of the nfs server hosting the fileshare.  Required.
# $share::	The exported fileshare on $server to mount.  Required.
# $fstype::     The filesystem type.  Default: 'nfs4'.
# $atboot::	Whether to mount the share at system boot time.
# $options::	Mount options.  This is a comma sparated string with no spaces.
# $remounts::   Whether the mount can be remounted.
# 
# === Usage:
# NFS v4 example:
#   nfs::mount {'/nfs4-data':
#     server => 'unxrhet01.ucop.edu',
#     share  => '/nfs-data',
#     options=> 'rw',
#   }
#
# NFS v3 example:
#  nfs::mount {'/nfs-data/apache':
#    fstype => 'nfs',
#    server => 'unxrhet01.ucop.edu',
#    share  => '/data/apache',
#    options=> 'rw,tcp',
#  }
#
define nfs::mount (
  $ensure   = 'mounted',
  $server,
  $share,
  $fstype   = 'nfs4',
  $atboot   = true,
  $options  = 'ro,sync,no_subtree_check',
  $remounts = undef,
) {

  # create the mountpoint directory named for the resource title
  $mountpoint        = $name
  $ensure_mountpoint = $ensure ? {
    'absent' => $ensure,
    default  => 'present',
  }
  nfs::mkdir_p { $mountpoint:
    ensure => $ensure_mountpoint,
  }

  # implement a puppet mount resource
  mount { $mountpoint:
    ensure   => $ensure,
    device   => "${server}:${share}",
    fstype   => $fstype,
    atboot   => $atboot,
    options  => $options,
    remounts => $remounts,
    require  => Nfs::Mkdir_p[$mountpoint],
  }

}
