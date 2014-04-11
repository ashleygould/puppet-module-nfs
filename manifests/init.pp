# = Class: nfs
#
# Manages NFS Clients
#
# === Provides:
# - install client packages
# - manage client service
# - create nfs mounts either from hiera_hash call or from $mounts param
#
# === Parameters:
# $ensure::	Ensure nfs client services are running or not.
# $enable::	Enable nfs client services to start at boot.
# $mounts::	Hash of instances of type nfs::mount to be mounted.  Optional.
# $hiera_hash::	Boolean to use hiera_hash function to merge all found instances of nfs::mounts.
#
# === Usage:
#  include nfs
#
#    or
#
#  class { nfs:
#    mounts => {
#      '/webnfs/www-data' => {
#        server => 'unxnfst01',
#        share  => '/nfs-ucop/www-data',
#        fstype => 'nfs4',
#        options=> 'rw,hard,intr',
#      },
#      '/data/www-data' => {
#        server => 'unxnfst01',
#        share  => '/data/nfs-ucop/www-data',
#        fstype => 'nfs',
#        options=> 'rw,hard,intr,tcp',
#      },
#    } 
#  }
#
class nfs (
  $ensure     = $nfs::params::client_service_ensure,
  $enable     = true,
  $hiera_hash = false,
  $mounts     = undef,
) inherits nfs::params {

  $supporting_class = $nfs::params::supporting_class
  $client_package   = $nfs::params::client_package
  $client_service   = $nfs::params::client_service

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
      ensure    => $ensure,
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
