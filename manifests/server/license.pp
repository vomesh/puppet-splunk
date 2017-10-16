# vim: ts=2 sw=2 et
class splunk::server::license (
  $lm = $splunk::lm,
  $lm_master = $splunk::lm_master,
  $splunk_os_user = $splunk::real_splunk_os_user,
  $splunk_os_group = $splunk::real_splunk_os_group,
  $splunk_dir_mode = $splunk::real_splunk_dir_mode,
  $splunk_file_mode = $splunk::real_splunk_file_mode,
  $splunk_app_precedence_dir = $splunk::splunk_app_precedence_dir,
  $splunk_app_replace = $splunk::splunk_app_replace,
  $splunk_home = $splunk::splunk_home
){
  $splunk_app_name = 'puppet_common_license_client_base'
  if $lm == undef {
    file {"${splunk_home}/etc/apps/${splunk_app_name}":
      ensure  => absent,
      recurse => true,
      purge   => true,
      force   => true,
    }
  } else {
    file { ["${splunk_home}/etc/apps/${splunk_app_name}",
            "${splunk_home}/etc/apps/${splunk_app_name}/${splunk_app_precedence_dir}",
            "${splunk_home}/etc/apps/${splunk_app_name}/metadata",]:
      ensure => directory,
      owner  => $splunk_os_user,
      group  => $splunk_os_group,
      mode   => $splunk_dir_mode,
    }
    -> file { "${splunk_home}/etc/apps/${splunk_app_name}/${splunk_app_precedence_dir}/server.conf":
      ensure  => present,
      owner   => $splunk_os_user,
      group   => $splunk_os_group,
      mode    => $splunk_file_mode,
      replace => $splunk_app_replace,
      content => template("splunk/${splunk_app_name}/local/server.conf"),
    }
  }
  if $lm_master == "true" {
    $splunk_lm_app_name = 'puppet_license_master_base'
    # Push the license(s) to the license server.
    file { "${splunk_home}/etc/licenses/enterprise/":
      ensure => directory,
      recurse => true,
      source => "puppet://modules/splunk/files/licenses/",
      owner  => $splunk_os_user,
      group  => $splunk_os_group,
      mode   => $splunk_dir_mode,
    }
    -> file { "${splunk_home}/etc/apps/${splunk_lm_app_name}/${splunk_app_precedence_dir}/server.conf":
        ensure  => present,
        owner   => $splunk_os_user,
        group   => $splunk_os_group,
        mode    => $splunk_file_mode,
        replace => $splunk_app_replace,
        content => template("splunk/${splunk_lm_app_name}/local/server.conf"),
    }
  }
}

