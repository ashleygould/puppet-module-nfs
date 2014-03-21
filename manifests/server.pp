# == Class: nfs::server
#
# Manages an NFS Server
#
class nfs::server (
  $ensure = 'running',
  $enable = true,
  $exports_path   = '/etc/exports',
  #$exports_owner  = 'root',
  #$exports_group  = 'root',
  #$exports_mode   = '0644',
) {

  include 'nfs'

  if $nfs::nfs_server_package != undef {
    package { $nfs::nfs_server_package:
      ensure  => installed,
      require => Class['nfs'],
    }
  }


  #file { 'nfs_exports':
  #  ensure => file,
  #  path   => $exports_path,
  #  owner  => $exports_owner,
  #  group  => $exports_group,
  #  mode   => $exports_mode,
  #}


  concat {'/etc/exports':
    notify => Exec['update_nfs_exports'],
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


  if $nfs::nfs_server_service != undef {
    service { $nfs::nfs_server_service:
      ensure    => $ensure,
      enable    => $enable,
      require    => Class['nfs'],
    }
  } else {
    Service <| $title == 'nfs_client_service' |> {
      ensure     => $ensure,
      enable     => $enable,
      require    => Class['nfs'],
    }
  }


}
