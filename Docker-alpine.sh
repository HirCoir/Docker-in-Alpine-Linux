#!/bin/bash
hdocker=/usr/bin/hdocker
apk=/etc/apk/repositories
dockerbin=/usr/bin/docker
ip=$(curl ifconfig.me)
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
apk update && apk add curl bash figlet
clear
figlet -c Creado por HirCoir
sleep 3
else
   clear
   echo "No se ha encontrado un sistema operativo Alpine Linux."
   exit
fi
if [ -f "$hdocker" ]
then
echo ""
else
wget https://raw.githubusercontent.com/HirCoir/Docker-in-Alpine-Linux/main/bin/hdocker -O /usr/bin/hdocker
chmod 777 /usr/bin/hdocker
fi
clear
echo "##########################################"
echo "# Elija que complementos desea instalar  #"
echo -e "\e[34m# 1) Docker                              # \e[0m"
echo -e "\e[36m# 2) Docker + Portainer Panel            # \e[0m"
echo -e "\e[32m# 3) Docker + Yacht Panel                # \e[0m"
echo -e "\e[35m# 4) Crear tunel Ngrok (Acceso a panel)  # \e[0m"
echo -e "\e[31m# 5) Eliminar Docker, Panel, Tunel Ngrok # \e[0m"
echo "# 6) Salir                               #"
echo "##########################################"
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
docker rm $(docker ps -a -q)
clear
sleep 4
docker volume create portainer_data
docker run -d -p 9000:9000 --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
echo ""
echo "Docker y Portainer se ha instalado correctamente."
echo "Acceda con la url http://$ip:9000"
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
sleep 2
sleep 2
docker rm $(docker ps -a -q)
sleep 4
clear
docker volume create yacht
docker run -d -p 9000:8000 -v /var/run/docker.sock:/var/run/docker.sock -v yacht:/config selfhostedpro/yacht
echo ""
echo "Docker y Yacht se ha instalado correctamente."
echo "Acceda con la url http://$ip:9000"
echo "Usuario: admin@yacht.local"
echo "Clave: pass"
else
   echo "Error. No se ha podido instalar Docker"
   exit
fi
        break;;
        [4]* ) 
echo "Obtenga su Token de la siguiente URL: https://dashboard.ngrok.com/get-started/your-authtoken"

read -p "Ingresa SOLO TU TOKEN NGROK: " ngrok_token
echo ""
if [ -f /usr/bin/ngrok ]
then
echo "Ngrok Encontrado"
killall ngrok
killall ngrok
killall ngrok
killall ngrok
killall ngrok
killall ngrok
killall ngrok
else
mkdir /tmp/
wget -O /tmp/ngrok.tgz https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.tgz
tar -xzvf /tmp/ngrok.tgz --directory /usr/bin/
rm /tmp/ngrok.tgz
fi
ngrok authtoken $ngrok_token

echo "Iniciando Ngrok en el puerto"
nohup ngrok http 9000 &>/dev/null &

#echo -n "Extracting ngrok public url ."
NGROK_PUBLIC_URL=""
while [ -z "$NGROK_PUBLIC_URL" ]; do
  # Run 'curl' against ngrok API and extract public (using 'sed' command)
  export NGROK_PUBLIC_URL=$(curl --silent --max-time 10 --connect-timeout 5 \
                            --show-error http://127.0.0.1:4040/api/tunnels | \
                            sed -nE 's/.*public_url":"https:..([^"]*).*/\1/p')
  sleep 1
  echo -n "."
done
clear
echo
echo "Listo, URL de acceso: https://$NGROK_PUBLIC_URL"
echo "Acceso via IP: http://$ip:9000"
        break;;
        [5]* ) 
if [ -f "$dockerbin" ]
then
docker stop $(docker ps -a -q)
sleep 2
docker volume rm $(docker volume ls -q)
sleep 2
docker rm $(docker ps -a -q)
clear
service docker stop
apk del docker docker-compose
rc-update del docker boot
else
   echo "Error. No se ha encontrado Docker"
fi
if [ -f /usr/bin/ngrok ]
then
echo "Eliminando Ngrok"
killall ngrok &
killall ngrok
killall ngrok
killall ngrok
killall ngrok
killall ngrok
killall ngrok
clear
rm /usr/bin/ngrok
else
echo "No se ha encontrado Ngrok."
fi
        break;;
        [6]* ) exit; break;;        
        * ) exit;;
    esac
done
