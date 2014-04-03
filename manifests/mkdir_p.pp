# == Define: nfs::mkdir_p
#
# Provide `mkdir -p` functionality for a directory
#
# Idea is to use this mkdir_p in conjunction with a file resource
#
# Example usage:
#
#  nfs::mkdir_p { '/some/dir/structure': }
#
#  file { '/some/dir/structure':
#    ensure  => directory,
#    require => Nfs::Mkdir_p['/some/dir/structure'],
#  }
#
define nfs::mkdir_p (
  $ensure = 'present',
) {

  validate_absolute_path($name)

  if $ensure == 'present' {
    exec { "mkdir_p-${name}":
      command => "mkdir -p ${name}",
      unless  => "test -d ${name}",
      path    => '/bin:/usr/bin',
    }
  }
}
