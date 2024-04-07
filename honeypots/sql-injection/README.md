# SQL-injection

Based on `https://github.com/SunshineCTF/SunshineCTF-2019-Public/tree/master/Web/WrestlerBook`.

```shell
docker-compose build --no-cache --build-arg HOST_UID=$(id -u)
docker-compose up -d
```

To publish the honeypot to the interenet use nginx (`nginx.conf` presented in dir) or change `ports` on `docker-compose.yaml`.
