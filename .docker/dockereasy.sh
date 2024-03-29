#!/bin/sh

echo "Docker Easy"
echo "Created by William Koller <developkoller@gmail.com>"

source config.sh

platform='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
   platform='linux'
elif [[ "$unamestr" == 'MSYS_NT-10.0-WOW' ]] || [[ "$unamestr" == 'MINGW32_NT-10.0-WOW' ]]; then
   platform='windows10'
elif [[ "$unamestr" == 'FreeBSD' ]]; then
   platform='freebsd'
fi

if [[ $platform == 'linux' ]]; then
   HOSTS_FILE=/etc/hosts
elif [[ $platform == 'windows10' ]]; then
   HOSTS_FILE=/c/Windows/System32/drivers/etc/hosts
fi

IP=$(docker-machine ip $(docker-machine active))
NEW_HOST="${IP} ${DOMAIN_NAME}"

down()
{
    docker-compose -p ${DOMAIN_NAME} down
    echo "Removing hosts entry ..."
    sed -i "s/${NEW_HOST}/ /g" ${HOSTS_FILE}
    sed '/^\s*$/d' ${HOSTS_FILE}
    echo "Ok!"
}

exec()
{
    docker-compose -p ${DOMAIN_NAME} exec -T $2 bash
}

logs()
{
    docker-compose -p ${DOMAIN_NAME} logs -f
}

up()
{
    docker-compose -p ${DOMAIN_NAME} up -d --build
    echo "Updating hosts file..."
    updateHosts
    echo "Hosts updated!"
}

restart()
{
    docker-compose -p ${DOMAIN_NAME} restart $1
}

ps()
{
    docker-compose -p ${DOMAIN_NAME} ps
}

updateHosts()
{
    sed '/^\s*$/d' ${HOSTS_FILE}
    echo "" >> $HOSTS_FILE
    echo $NEW_HOST >> $HOSTS_FILE
    echo "Added new host: ${NEW_HOST}"
    echo "in ${HOSTS_FILE}"
}

if [ -z "$1" ]
then
    echo "Please inform the command..."
    exit;
fi

eval "\$1"
