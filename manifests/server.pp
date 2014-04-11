# = Class: nfs::server
#
# Manages an NFS Server
#
# === Provides:
# - install nfs server rpms if needed
# - manage /etc/sysconfig/nfs
# - manage /etc/exports with concat
# - run nfsserver service if needed
# - run nfslock service if needed
#
# === Parameters:
# $ensure::      Ensures all defined nfs server services are running or not.
# $enable::      Enable all defined nfs server services to start at boot.
# $mountd_port:: Assign port rpc.mountd listens on.  Optional.
# $statd_port::  Assign port rpc.statd listens on.  Optional.
# $lockd_port::  Assign port rpc.lockd listens on.  Optional.
# $exports::     Hash of instances of type nfs::export to be exported.  Optional.
# $hiera_hash::  Boolean to use hiera_hash function to merge all found instances of nfs::exports.
#
# === Usage:
#  class { nfs::server:
#    statd_port  => '4004',
#    mountd_port => '4002',
#    lockd_port  => '4003',
#  }
#
class nfs::server (
  $ensure         = 'running',
  $enable         = true,
  $mountd_port    = '',
  $statd_port     = '',
  $lockd_port     = '',
  $hiera_hash     = false,
  $exports        = undef,
) {

  include 'nfs'

  $server_package  = $nfs::params::server_package
  $server_service  = $nfs::params::server_service
  $nfslock_service = $nfs::params::nfslock_service

  # install any server rpms
  if $server_package != undef {
    package { $server_package:
      ensure  => installed,
      require => Class['nfs'],
    }
  }


  # manage /etc/sysconfig/nfs
  file { '/etc/sysconfig/nfs':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("nfs/nfs.sysconfig.${::osfamily}.erb"),
    notify  => Service[$nfs::server_service],
  }


  # manage /etc/exports with concat
  concat {'/etc/exports':
    notify => Exec['update_nfs_exports'],
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }
  concat::fragment{ 'nfs_exports_header':
    target  => '/etc/exports',
    content => 
      "# This file is configured through the nfs::server puppet module\n",
    order   => 01,
  }
  exec { 'update_nfs_exports':
    command     => 'exportfs -ra',
    path        => '/bin:/usr/bin:/sbin:/usr/sbin',
    refreshonly => true,
  }


  # run nfsserver service if is there is one
  if $server_service != $nfs::client_service {
    service { $server_service:
      ensure    => $ensure,
      enable    => $enable,
      require   => Class['nfs'],
    }
  }

  # run nfslock service if is there is one
  if $nfslock_service {
    service { $nfslock_service:
      ensure    => $ensure,
      enable    => $enable,
      require   => Class['nfs'],
      subscribe => File['/etc/sysconfig/nfs'],
    }
  }


  # validate $hiera_hash boolean
  if type($hiera_hash) == 'string' {
    $hiera_hash_real = str2bool($hiera_hash)
  } else {
    $hiera_hash_real = $hiera_hash
  }
  validate_bool($hiera_hash_real)


  # create nfs exports either from hiera_hash call or from $exports param
  if $exports != undef {
    
    if $hiera_hash_real == true {
      $exports_real = hiera_hash('nfs::exports')
    } else {
      $exports_real = $exports
      notice('Future versions of the nfs module will default nfs::hiera_hash to true')
    }
    
    validate_hash($exports_real)
    create_resources('nfs::export',$exports_real)
  }


}
