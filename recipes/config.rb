# nginx modsecurity module
template node[cookbook_name]['modsecurity']['module_file'] do
    source 'modsecurity_module.conf.erb'
    mode '0644'
    notifies :reload, 'service[nginx]', :delayed
end

# unicode mapping
template node[cookbook_name]['modsecurity']['unicode_mapping_file'] do
    source 'unicode.mapping'
    mode '0644'
end

# modsecurity configuration
template node[cookbook_name]['modsecurity']['config_file'] do
    source 'modsecurity.conf.erb'
end

# crs setup file
template node[cookbook_name]['owasp_crs']['setup_file'] do
    source "crs-setup.conf.erb"
end

# crs rule files
link node[cookbook_name]['owasp_crs']['rules_path'] do
    to "#{node[cookbook_name]['owasp_crs']['checkout_path']}/rules"
end
