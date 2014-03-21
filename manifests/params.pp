# == Class: nfs::params
#
# Default parameters for nfs classes
#
class nfs::params {

  case $::osfamily {
    'Debian': {
      $supporting_class      = 'rpcbind'
      $client_service_ensure = 'running'
      $nfs_client_package    = 'nfs-common'
      $nfs_server_package    = undef
      $nfs_server_service    = undef

      case $::lsbdistid {
        'Debian': {
          $nfs_client_service = 'nfs-common'
        }
        'Ubuntu': {
          $nfs_client_service = undef
        }
        default: {
          fail("nfs module only supports lsbdistid Debian and Ubuntu of osfamily Debian. Detected lsbdistid is <${::lsbdistid}>.")
        }
      }
    }

    'RedHat': {
      $client_service_ensure = 'running'
      $nfs_client_service    = 'nfs'
      $nfs_client_package    = 'nfs-utils'
      $nfs_server_service    = undef
      $nfs_server_package    = undef

      case $::lsbmajdistrelease {
        '5': {
          $supporting_class   = 'nfs::idmap'
        }
        '6': {
          $supporting_class   = ['nfs::idmap', 'rpcbind']
        }
        default: {
          fail("nfs module only supports EL 5 and 6 and lsbmajdistrelease was detected as <${::lsbmajdistrelease}>.")
        }
      }
    }

    'Suse' : {
      $client_service_ensure = undef
      $nfs_client_service    = 'nfs'
      $nfs_server_service    = 'nfsserver'

      case $::lsbmajdistrelease {
        '10': {
          $supporting_class   = 'nfs::idmap'
          #$supporting_class   = ['nfs::idmap', 'portmap']
          $nfs_client_package = 'nfs-utils'
          $nfs_server_package = undef
        }
        '11': {
          $supporting_class   = ['nfs::idmap', 'rpcbind']
          $nfs_client_package = 'nfs-client'
          $nfs_server_package = 'nfs-kernel-server'
        }
        default: {
          fail("nfs module only supports Suse 10 and 11 and lsbmajdistrelease was detected as <${::lsbmajdistrelease}>.")
        }
      }
    }

    default: {
      fail("nfs module only supports osfamilies Debian, RedHat, Solaris and Suse, and <${::osfamily}> was detected.")
    }
  }

}
