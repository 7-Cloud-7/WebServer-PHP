## Imagen de Apache con soporte para PHP:

 En el siguiente link (https://hub.docker.com/_/php) tenemos toda la informacion sobre las imágenes de PHP incluyendo un Apache con soporte para PHP, php:7.2-apache, que será la que usaremos.

 ## Archivo docker-compose.yml

Usaremos la imagen de apache "php:7.4-apache".
~~~
version: '3.9'
services:
  asir-apache:
    image: php:7.4-apache
    container_name: asir-apache
~~~

### Mapear puertos y volumenes

Añadiremos al archivo docker-compose.yml los siguientes datos para mapear los volumenes y añadir el puerto. Usaremos el volumen confApache para extraer los archivos de configuración que usaremos más tarde
~~~
version: '3.9'
services:
  asir-apache:
    image: php:7.4-apache
    container_name: asir-apache
    ports:
    - '8001:80'
    volumes:
      - /home/asir2a/Escritorio/SRI/Proyecto1/Apache:/var/www/html/
      - confApache:/etc/apache2
volumes:
  confApache:
~~~

## Copiar la configuración de confApache

Una vez extraidos los archivos al volumen "confApache" los copiaremos todos en la carpeta que queramos usar para la configuracion del apache y cambiaremos el archivo docker-compose.yml para mapear la carpeta de configuración de esta manera:

~~~
version: '3.9'
services:
  asir-apache:
    image: php:7.4-apache
    container_name: asir-apache
    ports:
    - '8001:80'
    volumes:
      - /home/asir2a/Escritorio/SRI/Proyecto1/Apache:/var/www/html/
      - /home/asir2a/Escritorio/SRI/Proyecto1/Apache/confApache:/etc/apache2
~~~

## Añadir un html a Apache

En el volumen que designamos a la carpeta var/www/html añadiremos un archivo index.php con el siguiente contenido:

~~~
<?php
echo "Hola mundo"
?>
~~~
![alt text](https://github.com/Igonzalezvila/Proyecto1/blob/main/Images/Screenshot%20from%202022-11-03%2016-18-16.png)

## Comprobacion del módulo PHP

Para comprobar que el soporte de PHP funciona añadiremos un archivo llamado info.php con el siguiente código:

~~~
<?php
phpinfo();
?>
~~~
Y comprobaremos que podemos acceder a él

![alt text](https://github.com/Igonzalezvila/Proyecto1/blob/main/Images/infoPHP.png?raw=true)


## Añadir un DNS

Para añadir el DNS usaremos esta configuración en el archivo docker-compose.yml

~~~
version: '3.9'
services:
  asir-apache:
    image: php:7.4-apache
    container_name: asir-apache
    ports:
    - '80:80'
    - '8000:8000'
    volumes:
      - /home/asir2a/Escritorio/SRI/Proyecto1/Apache:/var/www/html/
      - /home/asir2a/Escritorio/SRI/Proyecto1/Apache/confApache:/etc/apache2

  proyectDNS:
    image: internetsystemsconsortium/bind9:9.16
    container_name: asir_proyectDNS
    ports:
      - 5300:53/udp
      - 5300:53/tcp
    volumes:
      - /home/asir2a/Escritorio/SRI/Proyecto1/DNS/conf:/etc/bind
      - /home/asir2a/Escritorio/SRI/Proyecto1/DNS/zonas:/var/lib/bind
~~~

## Añadir IPs fijas

Usaremos el comando "network create --subnet=10.0.1.0/24 --gateway=10.0.1.1 proyect1_subnet". Una vez creada asignaremos las IPs y la red a cada uno de los contenedores en el archivo docker-compose.yml.
~~~
version: '3.9'
services:
  asir-apache:
    image: php:7.4-apache
    container_name: asir-apache
    networks:
      proyect1_subnet:
        ipv4_address: 10.0.1.11
    ports:
    - '80:80'
    - '8000:8000'
    volumes:
      - /home/asir2a/Escritorio/SRI/Proyecto1/Apache:/var/www/html/
      - /home/asir2a/Escritorio/SRI/Proyecto1/Apache/confApache:/etc/apache2

  proyectDNS:
    image: internetsystemsconsortium/bind9:9.16
    container_name: asir_proyectDNS
    networks:
      proyect1_subnet:
        ipv4_address: 10.0.1.10
    ports:
      - 5300:53/udp
      - 5300:53/tcp
    volumes:
      - /home/asir2a/Escritorio/SRI/Proyecto1/DNS/conf:/etc/bind
      - /home/asir2a/Escritorio/SRI/Proyecto1/DNS/zonas:/var/lib/bind
networks:
    proyect1_subnet:
      external: true
~~~

## Resolución de dominios

Para asignar el nombre de dominio a la IP y carpeta crearemos y editaremos los archivos de configuracion del DNS:

### Archivo named.conf
Ruta: /home/asir2a/Escritorio/SRI/Proyecto1/DNS/conf

En este archivo indicaremos que otros archivos de configuración se usarán.
~~~
include "/etc/bind/named.conf.options";
include "/etc/bind/named.conf.local";
~~~

### Archivo named.conf.local
Ruta: /home/asir2a/Escritorio/SRI/Proyecto1/DNS/conf
Aquí "fabulas.com" será el nombre del servidor y "db.fabulas.com" el archivo de la configuración de zonas que usará.
~~~
zone "fabulas.com." { 
        type master;
        file "/var/lib/bind/db.fabulas.com";
        notify explicit;
};
~~~

### Archivo db.fabulas.com
Ruta: /home/asir2a/Escritorio/SRI/Proyecto1/DNS/zonas

En este archivo "fabulas" se refiere al nombre del servidor, "oscuras" se refiere a la primera zona y "maravillosas" a la segunda. La IP 10.0.1.11 es la del servidor apache y la IP 10.0.1.10 la del DNS.

~~~
$TTL    3600
@       IN      SOA     ns.fabulas.com. igonzalezvila.danielcastelao.org. (
                   2007010401           ; Serial
                         3600           ; Refresh [1h]
                          600           ; Retry   [10m]
                        86400           ; Expire  [1d]
                          600 )         ; Negative Cache TTL [1h]
;
@       IN      NS      ns.fabulas.com.
@       IN      MX      10 serveremail.fabulas.org.

ns     IN       A       10.0.1.10
oscuras    IN      A       10.0.1.11
maravillosas	IN	A    10.0.1.11

pop     IN      CNAME   ns
www     IN      CNAME   etch
mail    IN      CNAME   etch
~~~

## Añadir un cliente y enlzarlo al servidor DNS

Con el parametro "dns: 10.0.1.11" le indicaremos que DNS usar mediante su IP

~~~
version: '3.9'
services:
  asir-apache:
    image: php:7.4-apache
    container_name: asir-apache
    networks:
      proyect1_subnet:
        ipv4_address: 10.0.1.11
    ports:
    - '80:80'
    - '8000:8000'
    volumes:
      - /home/asir2a/Escritorio/SRI/Proyecto1/Apache:/var/www/html/
      - /home/asir2a/Escritorio/SRI/Proyecto1/Apache/confApache:/etc/apache2
      - /home/asir2a/Escritorio/SRI/Proyecto1/Apache/confhttpdconfhttpd:/etc/httpd/conf

  asir_cliente_proyect:
    container_name: asir_cliente_proyect
    image: alpine
    networks:
      proyect1_subnet:
        ipv4_address: 10.0.1.12

    stdin_open: true
    tty: true #docker run -t
    dns:
      - 10.0.1.10 #ip del contenedor DNS

  proyectDNS:
    image: internetsystemsconsortium/bind9:9.16
    container_name: asir_proyectDNS
    networks:
      proyect1_subnet:
        ipv4_address: 10.0.1.10
    ports:
      - 5300:53/udp
      - 5300:53/tcp
    volumes:
      - /home/asir2a/Escritorio/SRI/Proyecto1/DNS/conf:/etc/bind
      - /home/asir2a/Escritorio/SRI/Proyecto1/DNS/zonas:/var/lib/bind
networks:
    proyect1_subnet:
      external: true
~~~

Con esto el cliente podra acceder a los archivos del servidor apache mediante los nombres de dominio oscuras.fabulas.com y maravillosas.fabulas.com