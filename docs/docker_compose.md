
## Docker Compose Guide

### Creating a compose file

```
version: '2'

services:
  nginx-php-fpm:
    image: liuyuqiang/nginx-php-fpm:latest
    restart: always
    environment:
      ENABLE_XDEBUG: '1'
```

### Running

```docker-compose up -d```

### Clean Up

```docker-compose down```
