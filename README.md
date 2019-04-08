![docker hub](https://img.shields.io/docker/stars/liuyuqiang/nginx-php-fpm.svg?style=flat)

## Overview

This is a Dockerfile/image to build a container for alpine nginx php-fpm :

- [https://github.com/nginxinc/docker-nginx/tree/master/stable/alpine](https://github.com/nginxinc/docker-nginx/tree/master/stable/alpine)

- [https://github.com/docker-library/php/tree/master/7.3/alpine3.9/fpm](https://github.com/docker-library/php/tree/master/7.3/alpine3.9/fpm)

### Version

| Software | Version |
|-----|-------|
| Alpine | 3.9 |
| Git | 2.20.1(System) |
| Nginx | 1.14.2 |
| PHP  | 7.3.3 |
| Python | 2.7.15(System) |
| Supervisor | 3.3.4(System) |


### Links

- [https://hub.docker.com/r/liuyuqiang/nginx-php-fpm/](https://hub.docker.com/r/liuyuqiang/nginx-php-fpm/)

## Quick Start

## Building

```
git clone https://github.com/liuyuqiang/nginx-php-fpm
cd nginx-php-fpm/
docker build -t nginx-php-fpm:latest .
```

### Pulling

```
docker pull liuyuqiang/nginx-php-fpm:latest
```

### Running

daemon mode
```
docker run --name="nginx-php-fpm" -d nginx-php-fpm
```
clean up mode
```
docker run --name="nginx-php-fpm" --rm nginx-php-fpm -t -i /bin/bash
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
