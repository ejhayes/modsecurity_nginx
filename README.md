# modsecurity nginx
This currently only works with the following:

- ModSecurity - commit: 61c11251b686c10d7886d96ee6d524b95cfff890 (v3.0.4, as of 5/23/2019)
- NginxConnector - commit: d7101e13685efd7e7c9f808871b202656a969f4b (1.0.x, as of 5/23/2019)
- Ubuntu 16.04.6 LTS
- Nginx: 1.15.8

## quickstart
To install modsecurity nginx module

- Unzip `libmodsecurity.zip` to `/usr/local/modsecurity`
- Unzip `nginx_modsecurity.zip` to `/usr/share/nginx/modules`
- Add line to `/etc/nginx/nginx/conf`: 
```
load_module modules/ngx_http_modsecurity_module.so;
...
modsecurity on;
modsecurity_rules_file /etc/nginx/modsecurity.conf;
```

- Install dependencies: `apt-get install -y libyajl-dev`
- Confirm working with: `nginx -t`

## building new versions
To build a new version, do the following:

```
# install dependencies (there's a lot of them)
apt-get install apache2-dev autoconf automake build-essential bzip2 checkinstall devscripts flex g++ gcc git graphicsmagick-imagemagick-compat graphicsmagick-libmagick-dev-compat libaio-dev libaio1 libass-dev libatomic-ops-dev libavcodec-dev libavdevice-dev libavfilter-dev libavformat-dev libavutil-dev libbz2-dev libcdio-cdda1 libcdio-paranoia1 libcdio13 libcurl4-openssl-dev libfaac-dev libfreetype6-dev libgd-dev libgeoip-dev libgeoip1 libgif-dev libgpac-dev libgsm1-dev libjack-jackd2-dev libjpeg-dev libjpeg-progs libjpeg8-dev liblmdb-dev libmp3lame-dev libncurses5-dev libopencore-amrnb-dev libopencore-amrwb-dev libpam0g-dev libpcre3 libpcre3-dev libperl-dev libpng12-dev libpng12-0 libpng12-dev libreadline-dev librtmp-dev libsdl1.2-dev libssl-dev libssl1.0.0 libswscale-dev libtheora-dev libtiff5-dev libtool libva-dev libvdpau-dev libvorbis-dev libxml2-dev libxslt-dev libxslt1-dev libxslt1.1 libxvidcore-dev libxvidcore4 libyajl-dev make openssl perl pkg-config tar texi2html unzip zip zlib1g-dev -y

# build standalone module of libmodule
git clone --depth 1 https://github.com/SpiderLabs/ModSecurity.git
git submodule init
git submodule update
./build.sh

./configure --enable-standalone-module
make
make install

# get nginx connector
git clone --depth 1 https://github.com/SpiderLabs/ModSecurity.git

# nginx
# get version with `nginx -V`
curl -O http://nginx.org/download/nginx-1.15.8.tar.gz
tar -xvzf nginx-1.15.8.tar.gz
cd nginx-1.15.8

# configuration requires all the same options as the installed nginx package
# minus any --add-module params. also cannot use the --with-compat flag as
# it causes binary incompatibility issues...
./configure --add-dynamic-module=../ModSecurity-nginx --with-cc-opt='-g -O2 -fPIC -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2' --with-ld-opt='-Wl,-Bsymbolic-functions -fPIE -pie -Wl,-z,relro -Wl,-z,now' --prefix=/usr/share/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/^Cinx/uwsgi --with-debug --with-pcre-jit --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --with-http_auth_request_module --with-http_v2_module --with-http_dav_module --with-http_slice_module --with-threads --with-http_addition_module --with-http_dav_module --with-http_flv_module --with-http_geoip_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_image_filter_module --with-http_mp4_module --with-http_perl_module --with-http_random_index_module --with-http_secure_link_module --with-http_v2_module --with-http_sub_module --with-http_xslt_module --with-mail --with-mail_ssl_module --with-stream --with-stream_ssl_module --with-threads
```

At the end of this process you'll have files in:

- `/usr/local/modsecurity`
- `/path/to/nginxSourceCode/objs/ngx_http_modsecurity_module.so`

Those can be zipped up.

