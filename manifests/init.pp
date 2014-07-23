############################################################
# Class: aide
#
# Description:
#  Installs and configures aide, and disables prelinking
#
# Variables:
#  None
#
# Facts:
#  None
#
# Files:
#  aide/files/aide.conf
#  aide/files/aide.cron
#  aide/files/aidereset.cron
#
# Templates:
#  None
#
# Dependencies:
#  None
############################################################
class aide {

  # Install AIDE - RHEL-06-000016
  package { 'aide':
    ensure  => 'latest',
  }

  file { '/etc/aide.conf':
    owner  => 'root',
    group  => 'wheel',
    mode   => '0600',
    source => 'puppet:///modules/aide/aide.conf',
  }
  file { '/etc/cron.daily/aide':
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
    source => 'puppet:///modules/aide/aide.cron',
  }

  augeas { 'Disable Prelinking':
    context => '/files/etc/sysconfig/prelink',
    changes => [
      'set PRELINKING no',
    ],
    notify  => Exec['Turn off Prelinking'],
  }

  exec { 'Turn off Prelinking':
    # This will create the initial AIDE database if it doesn't already exist
    #'Initialize AIDE DB':
    #  command => '/usr/sbin/aide -i; /bin/cp /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz',
    #  onlyif  => '/usr/bin/test ! -f /var/lib/aide/aide.db.gz';
    command => '/usr/sbin/prelink -ua; /bin/rm /etc/prelink.cache',
    onlyif  => '/usr/bin/test -e /etc/prelink.cache',
  }

}
