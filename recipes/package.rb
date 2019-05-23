include_recipe 'apt'

# update list of available packages
apt_update

package 'unzip'
package 'git'

# install dependencies
package 'libyajl-dev'

# get libmodsecurity package
remote_file '/tmp/libmodsecurity.zip' do
    source "#{node[cookbook_name]['modsecurity']['repo']}/releases/download/#{node[cookbook_name]['modsecurity']['libmodsecurity']['version']}/libmodsecurity.zip"
    owner 'root'
    group 'root'
    mode 0755
    only_if { ! File.exists? "#{node[cookbook_name]['modsecurity']['libmodsecurity']['path']}/lib/libmodsecurity.so" }
end

# unzip modsecurity package
execute 'Unzip libmodsecurity' do
    command "unzip /tmp/libmodsecurity.zip -d #{File.expand_path(node[cookbook_name]['modsecurity']['libmodsecurity']['path'] + '/..')}"
    creates "#{node[cookbook_name]['modsecurity']['libmodsecurity']['path']}/lib/libmodsecurity.so"
    cwd '/tmp'
    only_if { ! File.exists? "#{node[cookbook_name]['modsecurity']['libmodsecurity']['path']}/lib/libmodsecurity.so" }
end

# get nginx connector
remote_file '/tmp/nginx_modsecurity.zip' do
    source "#{node[cookbook_name]['modsecurity']['repo']}/releases/download/#{node[cookbook_name]['modsecurity']['nginx_connector']['version']}/nginx_modsecurity.zip"
    owner 'root'
    group 'root'
    mode 0755
    only_if { ! File.exists? "#{node[cookbook_name]['modsecurity']['nginx_connector']['path']}/ngx_http_modsecurity_module.so" }
end

# install nginx connector
execute 'Unzip nginx-connector' do
    command "unzip /tmp/nginx_modsecurity.zip -d #{node[cookbook_name]['modsecurity']['nginx_connector']['path']}"
    creates "#{node[cookbook_name]['modsecurity']['nginx_connector']['path']}/ngx_http_modsecurity_module.so"
    cwd "/tmp"
    only_if { ! File.exists? "#{node[cookbook_name]['modsecurity']['nginx_connector']['path']}/ngx_http_modsecurity_module.so" }
end

# get crs rules from git
git node[cookbook_name]['owasp_crs']['checkout_path'] do
    repository node[cookbook_name]['owasp_crs']['repo']
    checkout_branch node[cookbook_name]['owasp_crs']['branch']
    user 'root'
    group 'root'
end