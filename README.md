![docker hub](https://img.shields.io/docker/stars/liuyuqiang/nginx-php-fpm.svg?style=flat)

## Overview

This is a Dockerfile/image to build a container for alpine nginx php-fpm :

- [https://github.com/nginxinc/docker-nginx/tree/master/stable/alpine](https://github.com/nginxinc/docker-nginx/tree/master/stable/alpine)

- [https://github.com/docker-library/php/tree/master/7.3/alpine3.9/fpm](https://github.com/docker-library/php/tree/master/7.3/alpine3.9/fpm)

### Version

| Software | Version |
|-----|-------|
| Docker | 18.09.4|
| Alpine | 3.9 |
| Git | 2.20.1 |
| Nginx | 1.15.11 |
| PHP  | 7.3.4 |
| Python | 2.7.15 |
| Supervisor | 3.3.4 |
| Perl | 5.26.3 |
| LuaJIT	|2.1-20190329(openresty/luajit2)|

### Docker Layout

- [Docker Layout](https://github.com/liuyuqiang/nginx-php-fpm/blob/master/docs/layout.md)

### PHP Extensions

- main extension

```
apcu bcmath pcntl openssl redis mongo xdebug protobuf grpc yaf yar swoole soap
```
- [PHP Extensions detail](https://github.com/liuyuqiang/nginx-php-fpm/blob/master/docs/php_extensions.md)

### Links

- [https://hub.docker.com/r/liuyuqiang/nginx-php-fpm/](https://hub.docker.com/r/liuyuqiang/nginx-php-fpm/)

## Quick Start

### Building

```
git clone https://github.com/liuyuqiang/nginx-php-fpm
cd nginx-php-fpm/
docker build -t nginx-php-fpm:v1.0.8 .
```

### Building custom args

- default enable php extension

```
ARG ENABLE_PHP_EXTENSION_XDEBUG=yes
ARG ENABLE_PHP_EXTENSION_GRPC=yes
ARG ENABLE_PHP_EXTENSION_SWOOLE=yes
ARG ENABLE_PHP_EXTENSION_YAF=yes
ARG ENABLE_PHP_EXTENSION_YAR=yes
```
- example

```
docker build -t nginx-php-fpm:v1.0.8 --build-arg ENABLE_PHP_EXTENSION_XDEBUG=no --build-arg ENABLE_PHP_EXTENSION_GRPC=yes --no-cache .
```

### Pulling

```
docker login --username=<docker username> --password=
docker pull liuyuqiang/nginx-php-fpm:v1.0.8
```

### Running

daemon mode
```
docker run --name="nginx-php-fpm" -d liuyuqiang/nginx-php-fpm:v1.0.8
```
clean up mode
```
docker run --name="nginx-php-fpm" --rm liuyuqiang/nginx-php-fpm:v1.0.8
```

### docker exec

```
docker exec -t -i nginx-php-fpm /bin/bash
```

### Restart php-fpm or nginx

```
supervisorctl restart php-fpm
supervisorctl restart nginx
```

## Using environment variables

```
sudo docker run -d -e 'YOUR_VAR=VALUE' nginx-php-fpm
```

You can then use PHP to get the environment variable into your code:

```
string getenv ( string $YOUR_VAR )
```

Another example would be:

```
<?php
echo $_ENV["APP_ENV"];
?>
```

## Guides

- [Kubernetes](https://github.com/liuyuqiang/nginx-php-fpm/blob/master/docs/kubernetes.md)
- [Docker Compose](https://github.com/liuyuqiang/nginx-php-fpm/blob/master/docs/docker_compose.md)
- [https://pkgs.alpinelinux.org/packages](https://pkgs.alpinelinux.org/packages)
