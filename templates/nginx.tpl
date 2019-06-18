server {
    listen   443 ssl;
    server_name  ${servername};
    access_log  ${logpath}/${servername}_access.log;
    error_log  ${logpath}/${servername}_error.log;

    gzip            on;
    gzip_min_length 1000;
    gzip_proxied    expired no-cache no-store private auth;
    gzip_types      text/html text/plain application/xml text/css application/x-javascript text/javascript;

    ssl on;
    ssl_certificate /etc/letsencrypt/live/${servername}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${servername}/privkey.pem;

    ssl_session_timeout 5m;
    ssl_session_cache shared:SSL:50m;

    # Diffie-Hellman parameter for DHE ciphersuites, recommended 2048 bits
    #  $$ openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048
    ssl_dhparam /etc/nginx/ssl/dhparam.pem;

    # modern configuration. tweak to your needs.
    ssl_protocols TLSv1.1 TLSv1.2 TLSv1;
    ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!3DES:!MD5:!PSK';
    ssl_prefer_server_ciphers on;

    # HSTS (ngx_http_headers_module is required) (15768000 seconds = 6 months)
    add_header Strict-Transport-Security max-age=15768000;

    resolver 8.8.8.8;

    location / {
        proxy_pass  http://unix:${buildout:directory}/gunicorn.sock;
        proxy_set_header X-Forwarded-Protocol ssl;
        proxy_set_header X-Forwarded-Ssl on;

        proxy_redirect              off;
        proxy_set_header            Host $host;
        proxy_set_header            X-Real-IP $remote_addr;
        proxy_set_header            X-Forwarded-For $proxy_add_x_forwarded_for;
        client_max_body_size        10m;
        client_body_buffer_size     128k;
        proxy_connect_timeout       120;
        proxy_send_timeout          120;
        proxy_read_timeout          120;
        proxy_buffer_size           4k;
        proxy_buffers               4 32k;
        proxy_busy_buffers_size     64k;
        proxy_temp_file_write_size  64k;
    }


    location /static  {
        alias ${buildout:directory}/../static;
        expires max;

       }
    location /media  {
        alias ${buildout:directory}/../media;
        expires max;
       }

    location /robots.txt {
        return 200 "User-agent: *\nDisallow: ";
    }


    error_page   500 502  503 504  /50x.html;
    location =  /50x.html {
        root    html;
    }
}

server {
    listen 80;
    server_name www.${servername} ${servername} www.gamerauntsia.com gamerauntsia.com;
    return 301 https://${servername}$request_uri;
}
