# = Define: nfs::export
#
# Add a exported filesystem line to /etc/exports using concat
#
# === Parameters:
# $name::       The resource title - the directory name of the export.
# $ensure::	Whether to add or remove the export line.  Default 'present'.
# $clients::	List of clients and their mount options.
#
# === Usage:
#   nfs::bindmount { '/exports/nfs-data':
#     device => '/data',
#   }
#
define nfs::export (
  $ensure  = 'present',
  $clients = 'localhost(ro)',
) {

  if $ensure != 'absent' {
    $line = "${name} ${clients}\n"

    concat::fragment{
      "${name}":
        target  => '/etc/exports',
        content => "${line}"
    }
  }
}

