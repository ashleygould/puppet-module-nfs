# == Class: nfs
#
# Manages NFS
#
class nfs (
  $supporting_class      = $nfs::params::supporting_class,
  $nfs_client_package    = $nfs::params::nfs_client_package,
  $nfs_client_service    = $nfs::params::nfs_client_service,
  $nfs_server_package    = $nfs::params::nfs_server_package,
  $nfs_server_service    = $nfs::params::nfs_server_service,
  $client_service_ensure = $nfs::params::client_service_ensure,
  $client_service_enable = true,
  $hiera_hash            = false,
  $mounts                = undef,
) inherits nfs::params {


  # include required supporting classes
  if $supporting_class != undef {
    include $supporting_class
  }


  # validate $hiera_hash boolean
  if type($hiera_hash) == 'string' {
    $hiera_hash_real = str2bool($hiera_hash)
  } else {
    $hiera_hash_real = $hiera_hash
  }
  validate_bool($hiera_hash_real)


  # install client packages
  package { $nfs_client_package:
    ensure => present,
  }


  # manage client service
  if $nfs_client_service {
    service { 'nfs_client_service':
      ensure    => $nfs_client_service_ensure,
      name      => $nfs_client_service,
      enable    => $enable,
      subscribe => Package[$nfs_client_package],
    }
  }

  
  # create nfs mounts either from hiera_hash call or from $mounts param
  if $mounts != undef {

    if $hiera_hash_real == true {
      $mounts_real = hiera_hash('nfs::mounts')
    } else {
      $mounts_real = $mounts
      notice('Future versions of the nfs module will default nfs::hiera_hash to true')
    }

    validate_hash($mounts_real)
    create_resources('nfs::mount',$mounts_real)
  }

}
