class e8::ui_puppet (
  String $uiclient_default_version = '1000-PUSH-2904-93a8207',
  String $uap_default_version = '57-9.2.0-GA-e1829cd',
  String $assets_default_version = '134-PUSH-2904-a7c099f',
  String $assets_base_url = 'assets-qa-hadron.yesmail.com',
  String $user_admin_portal_url = 'uap-qa-hadron.yesmail.com/#users',
  String $ga_code = 'UA-1912993-13',
  String $ga_domain = 'platform-qa-hadron.yesmail.com',
  Integer $require_js_wait_seconds = 15,
  String $auth_server_url = 'https://au-qa2.yesmail.com',
  String $client_id = '5',
  String $redirect_uri = '//platform-qa-hadron.yesmail.com',
  String $logout_redirect_uri = '//platform-qa-hadron.yesmail.com',
  Boolean $hadronized = true,
  String $hadron_urls = "\"http://illuminaire.yesmail.com\",\"http://illuminaireqa.yesmail.com\"",

  String $assets_base_url_uap = 'assets-qa-hadron.yesmail.com',
  String $platform_url_uap = 'platform-qa-hadron.yesmail.com',
  String $ga_code_uap = 'UA-1912993-15',
  String $ga_domain_uap = 'uap-qa-hadron.yesmail.com',
  String $auth_server_url_uap = 'https://au-qa2.yesmail.com',
  String $client_id_uap = '7',
  String $redirect_uri_uap = '//uap-qa-hadron.yesmail.com',
  String $logout_redirect_uri_uap = '//uap-qa-hadron.yesmail.com',
  Boolean $hadronized_uap = true,
  String $hadron_urls_uap = "\"http://illuminaire.yesmail.com\",\"http://illuminaireqa.yesmail.com\"",

  String $uap_url = 'uap-qa-hadron.yesmail.com',
  String $assets_url = 'assets-qa-hadron.yesmail.com',
  String $service_url = 'http://localhost:8080/ui-service/',
  String $default_import_url = 'http://viryespagq401.postdirect.com/import/',
  String $default_ui_url = 'http://viryespagq401.postdirect.com/ui/',
  String $aaa_url = 'http://aaa-qa-hadron.yesmail.com/aaa/',

  String $import1_url = 'impurl1',
  String $import2_url = 'impurl2',
  String $ui1_url = 'uiurl1',
  String $ui2_url = 'uiuel2',

) {

  require ::e8::dev_user

#####DEFINE VERSIONS###
if defined('$::uiclientvsn') {
  $uiclient_version = $::uiclientvsn
} else {
  $uiclient_version = "${uiclient_default_version}"
}

if defined('$::uapvsn') {
  $uap_version = $::uapvsn
} else {
  $uap_version = "${uap_default_version}"
}

if defined('$::assetsvsn') {
  $assets_version = $::assetsvsn
} else {
  $assets_version = "${assets_default_version}"
}

#####Define import urls per node###
case $::mode {
    'import1': {
      $import_url = "${import1_url}"
      $ui_url = "${ui1_url}"
    }
    'import2': {
      $import_url = "${import2_url}"
      $ui_url = "${ui2_url}"
    }
    default: {
      $import_url = "${default_import_url}"
      $ui_url = "${default_ui_url}"
    }
  }
################
  Exec {
    path => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
  }

  File {
    owner => 'dev',
    group => 'dev',
    mode  => '0644',
  }

#######UI-CLEINT#########
  file { ['/opt/enterprise/prod_ui7-httpd']:
    ensure  => directory,
    recurse => true,
    owner   => 'dev',
    group   => 'dev',
  }

### Download the zip
  exec { 'zipfile':
    command => "rm -rf /opt/enterprise/prod_ui7-httpd/* ; wget http://artifactory.aws.p0.com:8081/artifactory/magellan-release-local/com/yesmail/magellan/hadron-interactive-suite/${uiclient_version}/hadron-interactive-suite-${uiclient_version}.zip",
    cwd     => '/opt/enterprise/prod_ui7-httpd',
    creates => "/opt/enterprise/prod_ui7-httpd/hadron-interactive-suite-${uiclient_version}.zip",
    notify  => Exec['unzip_file'],
  }

##unzip the file
  exec { 'unzip_file':
    cwd     => '/opt/enterprise/prod_ui7-httpd',
    command => "unzip /opt/enterprise/prod_ui7-httpd/hadron-interactive-suite-${uiclient_version}.zip -d ${uiclient_version}",
    creates => "/opt/enterprise/prod_ui7-httpd/${uiclient_version}",
  }

## Linking latest version
  file {'/opt/enterprise/prod_ui7-httpd/htdocs':
    ensure => 'link',
    target => "/opt/enterprise/prod_ui7-httpd/${uiclient_version}",
  }

## Linking conf directory
  exec { 'link_conf':
    cwd     => '/opt/enterprise/prod_ui7-httpd/htdocs/js/config',
    command => 'ln -s /opt/enterprise/prod_ui7-httpd/htdocs/js/config/`ls /opt/enterprise/prod_ui7-httpd/htdocs/js/config/` /opt/enterprise/prod_ui7-httpd/htdocs/js/config/current',
    creates => '/opt/enterprise/prod_ui7-httpd/htdocs/js/config/current',
  }

##Deploy the config per environment
  file { '/opt/enterprise/prod_ui7-httpd/htdocs/js/config/current/config.js':
    ensure  => file,
    content => epp('e8/ui_puppet/config.js.epp'),
    notify  => Service['httpd'],
  }

#######UAP#####

  file {'/opt/enterprise/prod_uap-httpd':
    ensure  => directory,
    recurse => true,
    owner   => 'dev',
    group   => 'dev',
  }

### Download the zip
  exec { 'zipfile_uap':
    command => "rm -rf /opt/enterprise/prod_uap-httpd/* ; wget http://artifactory.aws.p0.com:8081/artifactory/magellan-release-local/com/yesmail/magellan/enterprise-ui-admin/${uap_version}/enterprise-ui-admin-${uap_version}.zip",
    cwd     => '/opt/enterprise/prod_uap-httpd',
    creates => "/opt/enterprise/prod_uap-httpd/enterprise-ui-admin-${uap_version}.zip",
    notify  => Exec['unzip_file_uap'],
  }

##unzip the file
  exec { 'unzip_file_uap':
    cwd     => '/opt/enterprise/prod_uap-httpd',
    command => "unzip /opt/enterprise/prod_uap-httpd/enterprise-ui-admin-${uap_version}.zip -d ${uap_version}",
    creates => "/opt/enterprise/prod_uap-httpd/${uap_version}",
  }

## Linking latest version
  file {'/opt/enterprise/prod_uap-httpd/htdocs':
    ensure => 'link',
    target => "/opt/enterprise/prod_uap-httpd/${uap_version}",
  }

## Linking conf directory
  exec { 'link_uap_conf':
    cwd     => '/opt/enterprise/prod_uap-httpd/htdocs/js/config',
    command => 'ln -s /opt/enterprise/prod_uap-httpd/htdocs/js/config/`ls /opt/enterprise/prod_uap-httpd/htdocs/js/config/` /opt/enterprise/prod_uap-httpd/htdocs/js/config/current',
    creates => '/opt/enterprise/prod_uap-httpd/htdocs/js/config/current',
  }

  file { '/opt/enterprise/prod_uap-httpd/htdocs/js/config/current/config.js':
    ensure  => file,
    content => epp('e8/ui_puppet/config_uap.js.epp'),
    notify  => Service['httpd'],
  }

######ASSETS#########
  file {'/opt/enterprise/prod_app-assets-httpd':
    ensure  => directory,
    recurse => true,
    owner   => 'dev',
    group   => 'dev',
  }

### Download the zip
  exec { 'zipfile_assets':
    command => "rm -rf /opt/enterprise/prod_app-assets-httpd/* ; wget http://artifactory.aws.p0.com:8081/artifactory/magellan-release-local/com/yesmail/magellan/enterprise-ui-assets/${assets_version}/enterprise-ui-assets-${assets_version}.zip",
    cwd     => '/opt/enterprise/prod_app-assets-httpd',
    creates => "/opt/enterprise/prod_app-assets-httpd/enterprise-ui-assets-${assets_version}.zip",
    notify  => Exec['unzip_file_assets'],
  }

##unzip the file
  exec { 'unzip_file_assets':
    cwd     => '/opt/enterprise/prod_app-assets-httpd',
    command => "unzip /opt/enterprise/prod_app-assets-httpd/enterprise-ui-assets-${assets_version}.zip -d ${assets_version}",
    creates => "/opt/enterprise/prod_app-assets-httpd/${assets_version}",
  }

## Linking latest version
  file {'/opt/enterprise/prod_app-assets-httpd/htdocs':
    ensure => 'link',
    target => "/opt/enterprise/prod_app-assets-httpd/${assets_version}",
    notify => Service['httpd'],
  }

#####APACHE#####
  package { 'httpd':
    ensure => present,
  }

  service { 'httpd':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
###manage apache config
  file { '/etc/httpd/conf/httpd.conf':
    ensure  => file,
    content => epp('e8/ui_puppet/httpd.conf.epp'),
    notify  => Service['httpd'],
  }

###manage apache config
  file { '/etc/httpd/conf.d/ui-service.conf':
    ensure  => file,
    content => epp('e8/ui_puppet/ui-service.conf.epp'),
    notify  => Service['httpd'],
  }

}
