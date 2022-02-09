# Linux Containers (LXD)

## A) Instalación e inicio LXD
Para la instalación de LXD bastará con ejecutar el siguiente comando [1], luego debemos loguearnos en el grupo creado [2], una hecho esto iniciamos el servicio con el comando [3]
```bash
[1] sudo apt-get install lxd -y
[2] newgrp lxd
[3] lxd init --auto
```

## B) Creación de contenedor 'server'
Para la creación del contenedor, se podrá realizar con el siguiente comando en donde se indica la imagen predefinida que queremos usar como base y el nombre del contenedor [1]. Para poder ver los contenedores usamos el comando [2], y si queremos ver más detalles del contendor usamos el comando [3]
```
[1] lxc launch ubuntu:20.04 server1
[2] lxc list
[3] lxc info server1
```

## C) Servidor web y acceso desde máquina host (física)

### I) Instalación y configuración
Para el servidor web lo haremos con apache, para ello lo podemos instalar ejecutando un comando desde la máquina host (virtual) [1]. Una vez finalizada la instalación verificamos el estado del servicio [2].
```bash
[1] lxc exec server1 -- apt-get install -y apache2
[2] lxc exec server1 -- systemctl status apache2
```
### II) Modificación archivo index.html
Primero vamos a verificar que exista el archivo index.html en el contenedor [1]. En la máquina host (virtual) tendremos un archivo index.html el cual es el que reemplazaremos por el existente en el contenedor. Ya con este archivo modificado lo reemplazaremos con el comando [2]. Con la ip del contenedor, la cual podemos obtener con el comando de la sección B.3 podremos ejecutar el comando [3] para ver qué devuelve la página.
```bash
[1] lxc exec server1 -- ls /var/www/html/
[2] lxc file push index.html server1/var/www/html/index.html
#	lxc file push [filename] [name_container]/[path+filename]
[3] curl 10.61.242.88
```
### III) Acceso desde máquina host (física)
Para poder acceder a la página por medio de nuestra red local, es necesario hacer un reenvío de puertos desde la máquina host (virtual) hacia el contenedor, esto ya que el contendor es un entorno aislado y no podemos acceder directamente. Esto lo podremos realizarlo con el siguiente comando [1], en donde se hace una se hace una redirección de puertos o una especie de binding o proxy entre un puerto de la máquina host (virtual) y el contenedor. Se debe indicar la ip de la máquina host (virtual) y la dirección local del contenedor, cada uno con los respectivos puestos. Podremos ver la configuración creada con el comando [2]. Ya con esto podremos probar desde la máquina host (física) con la ip y el puerto configurados.
```bash
[1] lxc config device add server1 myport80 proxy listen=tcp:192.168.56.5:7080 connect=tcp:127.0.0.1:80
[2] lxc config device show server1
```
## D) Configuración y acceso con SSH

### I) Habilitar SSH
Para habilitar el SSH podríamos hacerlo con comandos desde la máquina host (virtual), pero para mayor comodidad podemos acceder directamente al contenedor, recordemos que podemos ejecutar comando por lo que si ejecutamos bash nos abrirá este [1]. Luego abrimos el archivo de configuración de ssh [2], modificamos el valor del parámetro [3] y por último reiniciamos el servicio [4].
Agregamos un usuario el cual usaremos para acceder remotamente, en este caso será **remoto** con contraseña **remoto123**  [5].
```bash
[1] sudo lxc exec server1 bash
[2] vi /etc/ssh/sshd_config
[3] # PasswordAuthentication yes
[4] service sshd restart
[5] adduser remoto
```
### II) Reenvío de puertos
Recordemos que desde fuera no podemos acceder directamente al contenedor para ello haremos una redirección del puerto 22 del contenedor por uno mayor a 1023 de la máquina host (virtual) [1].
```bash
[1] lxc config device add server1 myport22 proxy listen=tcp:192.168.56.5:2222 connect=tcp:127.0.0.1:22
```
### III) Acceso desde la máquina client
Para poder acceder por medio de ssh desde otra máquina en este caso una máquina client (vagrant) debemos crear unas llaves ssh y la llave pública autorizarla desde el contenedor. Para ello entonces desde la máquina cliente ejecutamos [1]. Este comando nos hará unas preguntas, pero a todo le damos enter por fines prácticos.
Ahora bien, tenemos que autorizar la llave pública generada en el contenedor para ello entonces la debemos copiar, por fortuna existe un comando que nos ayuda con ello [2].
```bash
[1] ssh-keygen
[2] ssh-copy-id -p 2222 remoto@192.168.56.5
```
