## Imagen de Apache con soporte para PHP:

 En el siguiente link (https://hub.docker.com/_/php) tenemos toda la informacion sobre las imágenes de PHP incluyendo un Apache con soporte para PHP, php:7.2-apache, que será la que usaremos.

 ## Archivo docker-compose.yml

~~~
version: '3.9'
services:
  asir-apache:
    image: php:7.4-apache
    container_name: asir-apache
~~~

### Configurar puertos y volumenes

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

## Añadir un html a Apache

En el volumen que designamos a la carpeta var/www/html añadiremos un archivo index.php con el siguiente contenido:

~~~
<?php
echo "Hola mundo"
?>
~~~
![alt text](https://github.com/Igonzalezvila/Proyecto1/blob/main/Images/Screenshot%20from%202022-11-03%2016-18-16.png)