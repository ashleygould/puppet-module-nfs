# == Class: nfs::params
#
# Default parameters for nfs classes
#
class nfs::params {

  case $::osfamily {
    'Debian': {
      $supporting_class      = 'rpcbind'
      $client_service_ensure = 'running'
      $client_package    = 'nfs-common'
      $server_package    = undef
      $server_service    = undef

      case $::lsbdistid {
        'Debian': {
          $client_service = 'nfs-common'
        }
        'Ubuntu': {
          $client_service = undef
        }
        default: {
          fail("nfs module only supports lsbdistid Debian and Ubuntu of osfamily Debian. Detected lsbdistid is <${::lsbdistid}>.")
        }
      }
    }

    'RedHat': {
      $client_service_ensure = 'running'
      $client_service    = 'nfs'
      $client_package    = 'nfs-utils'
      $server_service    = undef
      $server_package    = undef

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
      $client_service    = 'nfs'
      $server_service    = 'nfsserver'

      case $::lsbmajdistrelease {
        '10': {
          $supporting_class   = 'nfs::idmap'
          #$supporting_class   = ['nfs::idmap', 'portmap']
          $client_package = 'nfs-utils'
          $server_package = undef
        }
        '11': {
          $supporting_class   = ['nfs::idmap', 'rpcbind']
          $client_package = 'nfs-client'
          $server_package = 'nfs-kernel-server'
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
