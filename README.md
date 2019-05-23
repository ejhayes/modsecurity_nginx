# Nginx ModSecurity Module
This currently only works with the following:

- ModSecurity - commit: 61c11251b686c10d7886d96ee6d524b95cfff890 (v3.0.4, as of 5/23/2019)
- NginxConnector - commit: d7101e13685efd7e7c9f808871b202656a969f4b (1.0.x, as of 5/23/2019)
- Ubuntu 16.04.6 LTS
- Nginx: 1.15.8

## Build the module
To build this module for Nginx you'll need to do the following (on Ubuntu 16.04):


### Install dependencies
Install dependencies:
    cd /tmp

    apt-get install apache2-dev autoconf automake build-essential bzip2 checkinstall devscripts flex g++ gcc git graphicsmagick-imagemagick-compat graphicsmagick-libmagick-dev-compat libaio-dev libaio1 libass-dev libatomic-ops-dev libavcodec-dev libavdevice-dev libavfilter-dev libavformat-dev libavutil-dev libbz2-dev libcdio-cdda1 libcdio-paranoia1 libcdio13 libcurl4-openssl-dev libfaac-dev libfreetype6-dev libgd-dev libgeoip-dev libgeoip1 libgif-dev libgpac-dev libgsm1-dev libjack-jackd2-dev libjpeg-dev libjpeg-progs libjpeg8-dev liblmdb-dev libmp3lame-dev libncurses5-dev libopencore-amrnb-dev libopencore-amrwb-dev libpam0g-dev libpcre3 libpcre3-dev libperl-dev libpng12-dev libpng12-0 libpng12-dev libreadline-dev librtmp-dev libsdl1.2-dev libssl-dev libssl1.0.0 libswscale-dev libtheora-dev libtiff5-dev libtool libva-dev libvdpau-dev libvorbis-dev libxml2-dev libxslt-dev libxslt1-dev libxslt1.1 libxvidcore-dev libxvidcore4 libyajl-dev make openssl perl pkg-config tar texi2html unzip zip zlib1g-dev -y

### Build libmodsecurity
Build libmodsecurity module like this:

    git clone --depth 1 https://github.com/SpiderLabs/ModSecurity.git
    cd ModSecurity
    git submodule init
    git submodule update
    ./build.sh

    ./configure --enable-standalone-module
    make
    make install

Libmodsecurity will be located at `/usr/local/modsecurity`. Zip up the whole directory.

### Build Nginx Connector
Grab Nginx source code to build connector:

    cd /tmp
    git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git

    # get version with `nginx -V`
    curl -O http://nginx.org/download/nginx-1.15.8.tar.gz
    tar -xvzf nginx-1.15.8.tar.gz
    cd nginx-1.15.8

    # configuration requires all the same options as the installed nginx package
    # minus any --add-module params. also cannot use the --with-compat flag as
    # it causes binary incompatibility issues...
    ./configure --add-dynamic-module=../ModSecurity-nginx --with-cc-opt='-g -O2 -fPIC -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2' --with-ld-opt='-Wl,-Bsymbolic-functions -fPIE -pie -Wl,-z,relro -Wl,-z,now' --prefix=/usr/share/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/^Cinx/uwsgi --with-debug --with-pcre-jit --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --with-http_auth_request_module --with-http_v2_module --with-http_dav_module --with-http_slice_module --with-threads --with-http_addition_module --with-http_dav_module --with-http_flv_module --with-http_geoip_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_image_filter_module --with-http_mp4_module --with-http_perl_module --with-http_random_index_module --with-http_secure_link_module --with-http_v2_module --with-http_sub_module --with-http_xslt_module --with-mail --with-mail_ssl_module --with-stream --with-stream_ssl_module --with-threads

    make

The nginx module is located at `./objs/ngx_http_modsecurity_module.so`.

## Using the built module
To use the module you'll need to install some stuff:

### Install dependencies
ModSecurity depends on `libyajl-dev` library:
```
apt-get update
apt-get install -y libyajl-dev
```

Then grab and extract the files from the releases tab:
- Unzip `libmodsecurity.zip` to `/usr/local/modsecurity`
- Unzip `nginx_modsecurity.zip` to `/usr/share/nginx/modules`
- Add line to `/etc/nginx/nginx/conf`: 

### Update Nginx config
Update `/etc/nginx/nginx.conf`:
```
...
load_module modules/ngx_http_modsecurity_module.so;
...
```

Then add modsecurity configuration to `/etc/nginx/conf.d/modsecurity.conf`:

```
modsecurity on;
modsecurity_rules_file /etc/nginx/modsecurity.conf;
```

The config file `/etc/nginx/modsecurity.conf` can be based off of: https://github.com/SpiderLabs/ModSecurity/blob/v3/master/modsecurity.conf-recommended

If you want to use the OWASP common ruleset you'll need to include the following to the end of `/etc/nginx/modsecurity.conf`:

```
Include ./crs-setup.conf
Include ./rules/*.conf
```

Where:
- `/etc/nginx/crs-setup.conf` = https://github.com/SpiderLabs/owasp-modsecurity-crs/blob/v3.2/dev/crs-setup.conf.example
- `/etc/nginx/rules` = https://github.com/SpiderLabs/owasp-modsecurity-crs/tree/v3.2/dev/rules

### Dummy site configuration
You can test out with a dummy site at `/etc/nginx/sites-enabled/mysite.conf`:

    server {
        listen 8090;
        server_name _;

        location / {
            stub_status on;
            access_log off;
        }
    }

Then try a dummy sql injection request:

    curl localhost:8090/nginx_status?id=%20UNION%20ALL%20SELECT%20NULL%2CNULL%2CNULL%2CNULL%2CNULL%2CNULL%2CNULL%2CNULL%2CNULL%2CNULL%23 HTTP/1.1", host: "localhost:8090 -v
    *   Trying 127.0.0.1...
    * Connected to localhost (127.0.0.1) port 8090 (#0)
    > GET /nginx_status?id=%20UNION%20ALL%20SELECT%20NULL%2CNULL%2CNULL%2CNULL%2CNULL%2CNULL%2CNULL%2CNULL%2CNULL%2CNULL%23 HTTP/1.1
    > Host: localhost:8090
    > User-Agent: curl/7.47.0
    > Accept: */*
    >
    < HTTP/1.1 403 Forbidden
    < Date: Fri, 14 Jun 2019 19:57:48 GMT
    < Content-Type: text/html
    < Content-Length: 146
    < Connection: keep-alive
    < Keep-Alive: timeout=5
    <
    <html>
    <head><title>403 Forbidden</title></head>
    <body>
    <center><h1>403 Forbidden</h1></center>
    <hr><center>nginx</center>
    </body>
    </html>
    * Connection #0 to host localhost left intact
    * Could not resolve host: HTTP
    * Closing connection 1

You should also see log data in `/var/log/nginx/error.log`

    ...
    2019/06/14 19:57:48 [error] 3456#3456: *242 [client 127.0.0.1] ModSecurity: Access denied with code 403 (phase 2). Matched "Operator `Ge' with parameter `5' against variable `TX:ANOMALY_SCORE' (Value: `15' ) [file "/etc/nginx/rules/REQUEST-949-BLOCKING-EVALUATION.conf"] [line "79"] [id "949110"] [rev ""] [msg "Inbound Anomaly Score Exceeded (Total Score: 15)"] [data ""] [severity "2"] [ver ""] [maturity "0"] [accuracy "0"] [tag "application-multi"] [tag "language-multi"] [tag "platform-multi"] [tag "attack-generic"] [hostname "127.0.0.1"] [uri "/nginx_status"] [unique_id "156054226835.457888"] [ref ""], client: 127.0.0.1, server: _, request: "GET /nginx_status?id=%20UNION%20ALL%20SELECT%20NULL%2CNULL%2CNULL%2CNULL%2CNULL%2CNULL%2CNULL%2CNULL%2CNULL%2CNULL%23 HTTP/1.1", host: "localhost:8090"
    ...

