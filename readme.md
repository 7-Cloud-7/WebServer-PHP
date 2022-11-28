## Imagen de Apache con soporte para PHP:

 En el siguiente link (https://hub.docker.com/_/php) tenemos toda la informacion sobre las imágenes de PHP incluyendo un Apache con soporte para PHP, php:7.2-apache, que será la que usaremos.

<br>

 ## Archivo docker-compose.yml

Usaremos la imagen de apache "php:7.4-apache".
~~~
version: '3.9'
services:
  asir-apache:
    image: php:7.4-apache
    container_name: asir-apache
~~~

<br>

### Mapear puertos y volumenes

Primero en el archivo de configuracion ports.conf añadiremos los puertos que vayamos a usar en cada caso, cada vez que añadamos un contenedor con puertos mapeados hay que añadirlos a este archivo también

~~~
Listen 80
Listen 8000

<IfModule ssl_module>
	Listen 443
</IfModule>

<IfModule mod_gnutls.c>
	Listen 443
</IfModule>
~~~

Añadiremos al archivo docker-compose.yml los siguientes datos para mapear los volumenes y añadir el puerto. Usaremos el volumen confApache para extraer los archivos de configuración que usaremos más tarde
~~~
version: '3.9'
services:
  asir-apache:
    image: php:7.4-apache
    container_name: asir-apache
    ports:
    - '8000:80'
    volumes:
      - /home/asir2a/Escritorio/SRI/Proyecto1/Apache:/var/www/html/
      - confApache:/etc/apache2
volumes:
  confApache:
~~~

<br>

## Copiar la configuración de confApache

Una vez extraidos los archivos al volumen "confApache" los copiaremos todos en la carpeta que queramos usar para la configuracion del apache y cambiaremos el archivo docker-compose.yml para mapear la carpeta de configuración de esta manera:

~~~
version: '3.9'
services:
  asir-apache:
    image: php:7.4-apache
    container_name: asir-apache
    ports:
    - '8000:80'
    volumes:
      - /home/asir2a/Escritorio/SRI/Proyecto1/Apache:/var/www/html/
      - /home/asir2a/Escritorio/SRI/Proyecto1/Apache/confApache:/etc/apache2
~~~

<br>

## Añadir un html a Apache

En el volumen que designamos a la carpeta var/www/html añadiremos un archivo index.php con el siguiente contenido:

~~~
<?php
echo "Hola mundo"
?>
~~~
![alt text](https://github.com/Igonzalezvila/Proyecto1/blob/main/Images/Screenshot%20from%202022-11-03%2016-18-16.png)

<br>

## Comprobacion del módulo PHP

Para comprobar que el soporte de PHP funciona añadiremos un archivo llamado info.php con el siguiente código:

~~~
<?php
phpinfo();
?>
~~~
Y comprobaremos que podemos acceder a él

![alt text](https://github.com/Igonzalezvila/Proyecto1/blob/main/Images/infoPHP.png?raw=true)


<br>

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

<br>

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

<br>

## Resolución de dominios

Para asignar el nombre de dominio a la IP y carpeta crearemos y editaremos los archivos de configuracion del DNS:

<br>

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

<br>

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

<br>

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

Con esto el cliente podrá acceder a los archivos del servidor apache mediante los nombres de dominio oscuras.fabulas.com y maravillosas.fabulas.com

<br>

## Configurar DirectoryIndex

Por norma general esta directiva se puede configurar en el archivo apache2.conf pero también está incluida en el archivo dir.conf dentro de la carpeta "mods-avaliable".

Para evitar problemas de orden configuraremos la directiva en ambos archivos de la siguiente forma por ejemplo:

~~~
<IfModule mod_dir.c>
	DirectoryIndex hola2.html hola.html
</IfModule>
~~~

El orden será de izquierda a derecha. En este ejemplo el archivo "hola2.html" se mostrará antes que "hola.html"

<br>

## Habilitar HTTPS (SSL)



Primero iremos a los archivos de configuración que habiamos copiado del contanedor y buscaremos el archivo "default-ssl.conf" en la carpeta "/confApache/sites-avaliable" y lo copiaremos en la carpeta "/confApache/sites-enabled". Con esto tendremos un nuevo sitio listo para habilitar con HTTPS, ahora habra que habilitarlo.

Abrimos una terminal en el contenedor del apache2 y usamos el comando "a2enmod ssl", vienen significando "apache2 enable mod ssl" y luego el comando "a2enmod rewrite". Si da algún error con archivos de la carperta "mods-avaliable" podemos borrarlos sin más.

Lo siguiente será editar el archivo apache2.conf y añadir las siguientes lineas:
~~~
<Directory /var/www/html>
AllowOverride All
</Directory>
~~~

Ahora hay que crear los certificados SSL para poder trabajar con ellos así que crearemos una carpeta dentro de la carpeta "confApache" y la llamaremos por ejemplo "certificate".

Una vez creada abriremos una terminal en esta carpeta y usaremos el comando:

~~~
openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out apache-certificate.crt -keyout apache.key
~~~

Este comando creara los archivos de certificado que necesitamos y tendremos que añadir la información que nos pide. Lo siguiente será editar el archivo "default-ssl.conf" que tenemos en la carpeta "sites-enabled" y añadiremos las rutas de los archvivos de certificado y descomentaremos la linea "SSLEngine on" en caso de que esté comentada.
~~~
<VirtualHost *:443>
        SSLEngine on
        SSLCertificateFile /etc/apache2/certificate/apache-certificate.crt
        SSLCertificateKeyFile /etc/apache2/certificate/apache.key
</VirtualHost>
~~~

Después reiniciaremos el servicio de pache2 con este comando:

~~~
service apache2 restart
~~~

Y por último mapearemos el puerto 433 en nuestro archivo "docker-compose.yml" con el resto de puertos ya mapeados.
~~~
    ports:
    - '80:80'
    - '8000:8000'
    - '443:443'
~~~

Como hemos editado el archivo docker-compose.yml deberemos usar los comandos "docker-compese down" y "docker-compese up" para reiniciar el sistema y listo.

Con ésto ya podremos acceder a nuestro sitio buscando en el navegador "https://localhost:443"

<br>

## Wireshark en docker

Es bastante simple, solo hay que añadir al archivo "docker-compose.yml" las siguientes lineas que podemos encontar en la propia pagina oficial de la imagen:

~~~
  wireshark:
    image: lscr.io/linuxserver/wireshark:latest
    container_name: wireshark
    cap_add:
      - NET_ADMIN
    security_opt:
      - seccomp:unconfined #optional
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/London
    volumes:
      - /path/to/config:/config
    ports:
      - 3000:3000 #optional
    restart: unless-stopped
~~~

Para acceder a él entraremos en el navegador y buscaremos "localhost:3000" y esperamos a que cargue, no necesita nada más.