#!/bin/bash
apk=/etc/apk/repositories
dockerbin=/usr/bin/docker
show_ip=$(curl ifconfig.me)
if [ -f "$apk" ]
then
echo "Alpine Linux encontrado"
echo "Actualizando Source List"
rm $apk
echo "#/media/sda/apks" >> $apk
echo "http://dl-cdn.alpinelinux.org/alpine/v3.16/main" >> $apk
echo "http://dl-cdn.alpinelinux.org/alpine/v3.16/community" >> $apk
echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> $apk
echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> $apk
echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> $apk
apk update && apk add curl bash
else
   clear
   echo "No se ha encontrado un sistema operativo Alpine Linux."
   exit
fi
clear
echo "#########################################"
echo "# Elija que complementos desea instalar #"
echo "# 1) Docker                             #"
echo "# 2) Docker + Portainer Panel           #"
echo "# 3) Docker + Yacht Panel               #"
echo "# 4) Eliminar Docker y Panel            #"
echo "# 5) Salir                              #"
echo "#########################################"
while true; do
    read -p "Elija una opcion: " op
    case $op in
        [1]* )
apk add openrc --no-cache
apk add docker docker-compose
rc-update add docker boot
service docker start
      break;;
        [2]* )
clear
echo "Instalando Docker, Docker Compose"
sleep 4
apk add openrc --no-cache
apk add docker docker-compose
rc-update add docker boot
service docker start
clear
echo "Si tiene contenedores este script los eliminara"
echo "Pulse [CTRL + C] para detener script"
if [ -f "$dockerbin" ]
then
docker stop $(docker ps -a -q)
docker volume rm $(docker volume ls -q)
docker rm $(docker ps -a -q)
clear
docker volume create portainer_data
docker run -d -p 9000:9000 --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
echo ""
echo "Docker y Portainer se ha instalado correctamente."
echo "Acceda con la url http://$show_ip:9000"
else
   echo "Error. No se ha podido instalar Docker"
   exit
fi
        break;;
        [3]* )
clear
echo "Instalando Docker, Docker Compose"
sleep 4
apk add openrc --no-cache
apk add docker docker-compose
rc-update add docker boot
service docker start
clear
echo "Si tiene contenedores este script los eliminara"
echo "Pulse [CTRL + C] para detener script"
sleep 8
if [ -f "$dockerbin" ]
then
docker stop $(docker ps -a -q)
docker volume rm $(docker volume ls -q)
docker rm $(docker ps -a -q)
clear
docker volume create yacht
docker run -d -p 9000:8000 -v /var/run/docker.sock:/var/run/docker.sock -v yacht:/config selfhostedpro/yacht
echo ""
echo "Docker y Yacht se ha instalado correctamente."
echo "Acceda con la url http://$show_ip:9000"
echo "Usuario: admin@yacht.local"
echo "Clave: pass"
else
   echo "Error. No se ha podido instalar Docker"
   exit
fi
        break;;
        [4]* ) 
if [ -f "$dockerbin" ]
then
docker stop $(docker ps -a -q)
docker volume rm $(docker volume ls -q)
docker rm $(docker ps -a -q)
clear
service docker stop
apk del docker docker-compose
rc-update del docker boot
else
   echo "Error. No se ha encontrado Docker"
   exit
fi
        break;;
        [5]* ) exit; break;;        
        * ) exit;;
    esac
done
