cookbook_name = 'modsecurity_nginx'

# modsecurity configuration
default[cookbook_name]['modsecurity']['repo'] = 'https://github.com/ejhayes/modsecurity_nginx'
default[cookbook_name]['modsecurity']['enabled'] = true
default[cookbook_name]['modsecurity']['config_file'] = '/etc/nginx/modsecurity.conf'
default[cookbook_name]['modsecurity']['module_file'] = '/etc/nginx/conf.d/modsecurity.conf'
default[cookbook_name]['modsecurity']['unicode_mapping_file'] = '/etc/nginx/unicode.mapping'
default[cookbook_name]['modsecurity']['libmodsecurity']['version'] = '1.0.0'
default[cookbook_name]['modsecurity']['libmodsecurity']['path'] = '/usr/local/modsecurity'
default[cookbook_name]['modsecurity']['nginx_connector']['version'] = '1.0.0'
default[cookbook_name]['modsecurity']['nginx_connector']['path'] = '/usr/share/nginx/modules'

# additional configuration
# from: https://github.com/SpiderLabs/ModSecurity/wiki/Reference-Manual-(v2.x)
default[cookbook_name]['modsecurity']['config']['rule_engine'] = 'DetectionOnly' # On,Off,DetectionOnly

# honeypot config
default[cookbook_name]['owasp_crs']['project_honeypot']['api_key'] = nil
default[cookbook_name]['owasp_crs']['project_honeypot']['block_search_ip'] = true
default[cookbook_name]['owasp_crs']['project_honeypot']['block_suspicious_ip'] = true
default[cookbook_name]['owasp_crs']['project_honeypot']['block_harvester_ip'] = true
default[cookbook_name]['owasp_crs']['project_honeypot']['block_spammer_ip'] = true

# owasp common ruleset (CRS)
default[cookbook_name]['owasp_crs']['repo'] = 'https://github.com/SpiderLabs/owasp-modsecurity-crs'
default[cookbook_name]['owasp_crs']['branch'] = 'v3.1.0/dev'
default[cookbook_name]['owasp_crs']['checkout_path'] = '/usr/share/nginx/owasp-modsecurity-crs'
default[cookbook_name]['owasp_crs']['setup_file'] = '/etc/nginx/crs-setup.conf'
default[cookbook_name]['owasp_crs']['rules_path'] = '/etc/nginx/rules'

# overwrite nginx configuration
default['nginx']['load_modules'] += ['modules/ngx_http_modsecurity_module.so']