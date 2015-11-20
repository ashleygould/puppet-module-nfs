# = Class: nfs::idmap
#
# Manages idmapd
#
# This class is almost verbatim from ghoneycutt original.
#
# === Provides:
# - install package
# - manage idmap.conf file
# - manage idmapd service
#
# === Parameters:
# $idmap_package::		String of the idmap package name.
# $idmapd_conf_path		The location of the config file.  Default: /etc/idmapd.conf
# $idmapd_conf_owner::		The owner of the config file.
# $idmapd_conf_group::		The group for the config file.
# $idmapd_conf_mode::		The mode for the config file.
# $idmapd_service_name::	String of the service name.
# $idmapd_service_enable::	Boolean value of enable parameter for idmapd service.  Default: true
# $idmapd_service_hasstatus::	Boolean value of hasstatus parameter for idmapd service.  Default: true
# $idmapd_service_hasrestart::	Boolean value of hasrestart parameter for idmapd service.  Default: true
#
# idmapd.conf options:
# $idmap_domain::	String value of domain to be set as local NFS domain.  Default: $::domain
# $ldap_server::	String value of ldap server name.
# $ldap_base::		String value of ldap search base.
# $local_realms::	String or array of local kerberos realm names.  Default: $::domain
# $translation_method::	String or array of mapping method to be used between NFS and local IDs.  Valid values is nsswitch, umich_ldap or static.  Default: nsswitch
# $nobody_user::	String of local user name to be used when a mapping cannot be completed.  Default: nobody
# $nobody_group::	String of local group name to be used when a mapping cannot be completed.  Default: nobody
# $verbosity::		Integer of verbosity level.  Default: 0
# $pipefs_directory::	String of the directory for rpc_pipefs.
#
#
# === Usage:
#   include nfs::idmap
#
class nfs::idmap (
  $idmap_package             = 'USE_DEFAULTS',
  $idmapd_conf_path          = '/etc/idmapd.conf',
  $idmapd_conf_owner         = 'root',
  $idmapd_conf_group         = 'root',
  $idmapd_conf_mode          = '0644',
  $idmapd_service_name       = 'USE_DEFAULTS',
  $idmapd_service_enable     = true,
  $idmapd_service_hasstatus  = true,
  $idmapd_service_hasrestart = true,
  # idmapd.conf options
  $idmap_domain              = $::domain,
  $ldap_server               = 'UNSET',
  $ldap_base                 = 'UNSET',
  $local_realms              = $::domain,
  $translation_method        = 'nsswitch',
  $nobody_user               = 'nobody',
  $nobody_group              = 'nobody',
  $verbosity                 = '0',
  $pipefs_directory          = 'USE_DEFAULTS',
) {

  # massage and validate parameters
  $is_idmap_domain_valid = is_domain_name($idmap_domain)
  if $is_idmap_domain_valid != true {
    fail("nfs::idmap::idmap_domain parameter, <${idmap_domain}>, is not a valid name.")
  }

  $is_ldap_server_valid = is_domain_name($ldap_server)
  if $is_ldap_server_valid != true {
    fail("nfs::idmap::ldap_server parameter, <${ldap_server}>, is not a valid name.")
  }
  validate_re($verbosity, '^(\d+)$', "verbosity parameter, <${verbosity}>, does not match regex.")

  $ldap_base_type = type($ldap_base)

  case $ldap_base_type {
    'String': {
      $ldap_base_real = $ldap_base
    }
    'Array': {
      $ldap_base_real = inline_template('<%= ldap_base.join(\',\') %>')
    }
    default: {
      fail("valid types for ldap_base are String and Array. Detected type is <${ldap_base_type}>")
    }
  }

  $local_realms_type = type($local_realms)

  case $local_realms_type {
    'String': {
      $local_realms_real = $local_realms
    }
    'Array': {
      $local_realms_real = inline_template('<%= local_realms.join(\',\') %>')
    }
    default: {
      fail("valid types for local_realms are String and Array. Detected type is <${local_realms_type}>")
    }
  }

  $translation_method_type = type($translation_method)

  case $translation_method_type {
    'String': {
      $translation_method_real = $translation_method
      validate_re($translation_method_real, '^(nsswitch|umich_ldap|static)$', "translation_method, <${translation_method}>, does not match regex.")
    }
    'Array': {
      $translation_method_real = inline_template('<%= translation_method.join(\',\') %>')
      # GH: TODO: write valid regex
    }
    default: {
      fail("valid types for translation_method are String and Array. Detected type is <${translation_method_type}>")
    }
  }

  case $::osfamily {
    'RedHat' : {
      $default_idmapd_service_name = 'rpcidmapd'
      $default_idmap_package       = 'nfs-utils-lib'
      $default_pipefs_directory    = 'UNSET'
    }
    'Suse' : {
      $default_idmap_package    = 'nfsidmap'
      $default_pipefs_directory = '/var/lib/nfs/rpc_pipefs'
      case $::lsbmajdistrelease {
        '10': {
      $default_idmapd_service_name = 'idmapd'
        }
        '11': {
      $default_idmapd_service_name = undef
        }
      }
    }
    default: {
      fail( "idmap only supports RedHat and Suse osfamilies, not ${::osfamily}" )
    }
  }

  if $idmapd_service_name == 'USE_DEFAULTS' {
    $idmapd_service_name_real = $default_idmapd_service_name
  } else {
    $idmapd_service_name_real = $idmapd_service_name
  }

  if $idmap_package == 'USE_DEFAULTS' {
    $idmap_package_real = $default_idmap_package
  } else {
    $idmap_package_real = $idmap_package
  }

  if $pipefs_directory == 'USE_DEFAULTS' {
    $pipefs_directory_real = $default_pipefs_directory
  } else {
    $pipefs_directory_real = $pipefs_directory
  }

  if $pipefs_directory_real != 'UNSET' {
    validate_absolute_path($pipefs_directory_real)
  }


  # install package
  package { $idmap_package_real:
    ensure => present,
  }


  # manage idmap.conf file
  file { 'idmapd_conf':
    ensure  => file,
    path    => $idmapd_conf_path,
    content => template("nfs/idmapd.conf.${::osfamily}.erb"),
    owner   => $idmapd_conf_owner,
    group   => $idmapd_conf_group,
    mode    => $idmapd_conf_mode,
    require => Package[$idmap_package_real],
  }


  # manage idmapd service
  if $idmapd_service_name_real != undef {

    service { 'idmapd_service':
      ensure     => running,
      name       => $idmapd_service_name_real,
      enable     => $idmapd_service_enable,
      hasstatus  => $idmapd_service_hasstatus,
      hasrestart => $idmapd_service_hasrestart,
      subscribe  => File['idmapd_conf'],
    }
  } elsif $::osfamily == 'Suse' and $::lsbmajdistrelease == '11' {
    Service <| title == 'nfs_client_service' |> {
      subscribe  => File['idmapd_conf'],
    }
  }
}
