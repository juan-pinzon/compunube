# Arquitectura de Microservicios

## A) Acciones previas a instalación de Docker
Primero vamos asegurarnos de que no haya una versión anterior o previamente instalada en la máquina, para ello ejecutamos [1]. Es necesario actualizar [2] y luego instalar algunas dependencias necesarias para que apt pueda descargar desde unos repositorios a través de https [3]. Luego debemos agregar la clave Gpg necesaria para Docker, a través del comando [4]. Puede verificar que tiene la clave con [5].
```bash
[1] sudo apt-get remove docker docker-engine docker.io containerd runc
[2] sudo apt-get update
[3] sudo apt-get install \  
	apt-transport-https \  
	ca-certificates \  
	curl \  
	gnupg-agent \  
	software-properties-common
[4] curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
[5] sudo apt-key fingerprint 0EBFCD88
```
## B) Instalación e inicio de Docker
Debemos agregar el repositorio de una versión estable de Docker para ello hacemos [1]. Luego Actualizar [2]. Y por último instalamos Docker y las herramientas que necesita [3].

```bash
[1] sudo add-apt-repository \  
	"deb [arch=amd64] https://download.docker.com/linux/ubuntu \  
	$(lsb_release -cs) \  
	stable"
[2] sudo apt-get update
[3] sudo apt-get install docker-ce docker-ce-cli containerd.io
```
## C) Servidor FTP, Dockerfile e imagen
Usaremos como imagen base una imagen de centos. Para ello la descargamos individualmente, aunque no es necesario, desde el Dockerfile se podría hacer [1]. Creamos luego nuestro archivo Dockerfile [2]. En este repositorio existe un archivo de configuración base para vsftpd (vsftpd.conf), el cual será copiado a la imagen. Una vez estructurado nuestro Dockerfile es hora de crear la imagen, para esto ejecutamos el comando [3]. En el repositorio se dejan el archivo de configuración (vsftps.conf) y el de arranque (entrypoint.sh).
```bash
[1] sudo docker pull centos
```
```bash
[2]
FROM alpine:3.15.0
ENV FTP_USER=foo \
	FTP_PASS=bar \
	GID=1000 \
	UID=1000

RUN apk add --no-cache --update \
	vsftpd==3.0.5-r1

COPY [ "/vsftpd.conf", "/etc" ]
COPY [ "/entrypoint.sh", "/" ]

CMD [ "/usr/sbin/vsftpd" ]
ENTRYPOINT [ "/entrypoint.sh" ]
EXPOSE 20/tcp 21/tcp 30000-30010/tcp
HEALTHCHECK CMD netstat -lnt | grep :21 || exit 1
# juancpinzon/ftpserver es el tag que llevará la imagen
[3] docker build -t juancpinzon/ftpserver .
```
## D) Container FTP
Ya con nuestra imagen construida podremos crear contenedores a partir de esta imagen. En nuestro caso vamos a crear una imagen con los mismos puertos, además de un data inicial, que se cargará por medio de un volumen de tipo bind-mount. El comando para esto es [1]
```bash
 docker run -d --env FTP_PASS=123 --env FTP_USER=juanc -p 20-21:20-21/tcp -p 30000-30010:30010/tcp --volume /root/ftp/data:/home/juanc --name ftp juancpinzon/ftpserver
```
## E) Aplicación web en Flask con Docker
Podemos correr una aplicación desde su código fuente con Docker, crear un entorno especial para esta aplicación y que no interfiera con otras aplicaciones. En este ejemplo lo haremos con una escrita en python con el framework flask. Para ello debemos clonar el siguiente repositorio [GitHub - omondragon/docker-flask-example](https://github.com/omondragon/docker-flask-example) [1]. Accedemos a la carpeta que se creo y que contiene el código fuente, además del archivo Dockerfile [2]. Después de esto debemos construir la imagen que vamos a usar como base para crear contenedores [3]. Cuando ya tengamos nuestra imagen construido podremos proceder a crear un contenedor que ponga a disposición la aplicación, según el Dockerfile del repositorio tiene el puerto 5000 expuesto por lo que este es el que debemos tener en cuenta [4]. Con esto podremos consultar con la ip y el puerto 5050.
```bash
[1] git clone https://github.com/omondragon/docker-flask-example.git flask
[2] cd flask
[3] docker build -t juancpinzon/flaskapp .
[4] docker run -d -p 5050:5000/tcp --name app juancpinzon/flaskapp
```
## F) Docker in LXD
Ejecutamos los siguientes comandos para dejar funcionando una webapp
```bash
lxc launch ubuntu-daily:16.04 docker -c security.nesting=true
lxc exec docker -- apt update
lxc exec docker -- apt dist-upgrade -y
lxc exec docker -- apt install docker.io -y
lxc exec docker -- docker run -d -e PORT=8080 -p 80:8080 --name web boxboat/hello-world-webapp
lxc list
```
Hacemos la prueba con curl http://[IP lXD container]
## G) Contenedor para Data Science e IA
Para la creación de un contenedor con algunas herramientas crearemos un Dockerfile que se basa en una imagen ya existente con esto, pero le agregaremos un par de herramientas. En este repositorio dejamos el archivo correspondiente.
```bash
docker build -t notebook_demo .
docker run --rm -p 8888:8888 notebook_demo
```
Con esto será suficiente para que arranque nuestro entorno, se le ha colocado el flag --rm para que cuando el container muera este sea borrado
