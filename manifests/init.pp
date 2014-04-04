# == Class: nfs
#
# Manages NFS
#
class nfs (
  $supporting_class      = $nfs::params::supporting_class,
  $client_package        = $nfs::params::client_package,
  $client_service        = $nfs::params::client_service,
  $server_package        = $nfs::params::server_package,
  $server_service        = $nfs::params::server_service,
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
  package { $client_package:
    ensure => present,
  }


  # manage client service
  if $client_service {
    service { 'nfs_client_service':
      ensure    => $client_service_ensure,
      name      => $client_service,
      enable    => $enable,
      subscribe => Package[$client_package],
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
