
# Smokeping - Monitoring network - An extension to Linuxserver.io Smokeping

[![smokeping](https://camo.githubusercontent.com/e0694ef783e3fd1d74e6776b28822ced01c7cc17/687474703a2f2f6f73732e6f6574696b65722e63682f736d6f6b6570696e672f696e632f736d6f6b6570696e672d6c6f676f2e706e67)](https://oss.oetiker.ch/smokeping/)

[Smokeping](https://oss.oetiker.ch/smokeping/) keeps track of your network latency. For a full example of what this application is capable of visit [UCDavis](http://smokeping.ucdavis.edu/cgi-bin/smokeping.fcgi). The [LinuxServer.io](https://linuxserver.io) Smokeping docker image is great. However it uses APT to install Smokeping. This is not the most recent version of Smokeping. So I've extended the base Linuxservice image with instructions to download the latest Smokeping and install it over the default Smokeping.

## Features added to LinuxServer.IO image
* Web-only mode (to only run the Apache service)
* Ping-only mode (to only collect data using Smokeping without the Apache service)
* Automatically download the latest Smokeping at startup of the container. (This can be disabled with NO_UPDATE=1).
* Slave mode - to run Smokeping in Slave mode 
* Patches - Allow Smokeping web UI running in a container to use a relative URL for the Filter function.
* Patches - TCPPing script starts tcptraceroute with sudo.

For more information on using this image - please see [divyavanmahajan/smokeping](https://github.com/divyavanmahajan/docker-smokeping)

## Usage

In addition to LinuxServer 
I have included a few extra environment variables.

NO_UPDATE=1 - Do not run the smokeping update when the container starts. This is useful if the container cannot access the Internet.
NO_WEB=1    - Only start the Smokeping part without the HTTP server. This will collect the data but will not display it.
NO_PING=1   - Only start the Apache HTTP server and do not ping. For this to work, this container must share the data and config folders with a NO_WEB=1 container.

If you want the container to run in Slave mode specify these variables.
Use the docker option "-h hostname" to give your container the name used to lookup your Slaves configuration.
SLAVE_SECRET - The secret shared key in your Slaves config file.
MASTER_URL  -  URL to contact the main server for the config file

Here are some example snippets to help you get started creating a container.

### docker standalone

```
docker create \
  --name=smokeping \
  -e PUID=1001 \
  -e PGID=1001 \
  -e TZ=Europe/London \
  -p 80:80 \
  -v </path/to/smokeping/config>:/config \
  -v </path/to/smokeping/data>:/data \
  --restart unless-stopped \
  divyavanmahajan/smokeping
```

## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 80` | Allows HTTP access to the internal webserver. |
| `-e PUID=1001` | for UserID - see below for explanation |
| `-e PGID=1001` | for GroupID - see below for explanation |
| `-e TZ=Europe/London` | Specify a timezone to use EG Europe/London |
| `-e NO_UPDATE=1` | Do not run the smokeping update when the container starts. This is useful if the container cannot access the Internet.|
| `-e NO_WEB=1`  | Only start the Smokeping part without the HTTP server. This will collect the data but will not display it.|
| `-e NO_PING=1` | Only start the Apache HTTP server and do not ping. For this to work, this container must share the data and config folders with a NO_WEB=1 container.|
| `-e SLAVE_SECRET=123` | SLAVE mode required: The secret shared key in your Slaves config file.|
| `-e MASTER_URL=http://master:3333/smokeping/smokeping.cgi`| SLAVE mode required: URL to contact the main server for the config file|
| `-h container_hostname` | SLAVE mode required: Give your container the hostname it will use to contact the master server. This hostname is used in the Slaves configuration.|
| `-v /config` | Configure the `Targets` file here |
| `-v /data` | Storage location for db and application data (graphs etc) |
| `-v /cache` | Storage location for the cache images etc) |

## User / Group Identifiers

When using volumes (`-v` flags) permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance `PUID=1001` and `PGID=1001`, to find yours use `id user` as below:

```
  $ id username
    uid=1001(dockeruser) gid=1001(dockergroup) groups=1001(dockergroup)
```

&nbsp;
## Application Setup

- Once running the URL will be `http://<host-ip>/`.
- Basics are, edit the `Targets` file to ping the hosts you're interested in to match the format found there.
- Wait 10 minutes.

## More examples

### docker master and slave
```
docker create \
  --name=master \
  -e PUID=1001 \
  -e PGID=1001 \
  -e TZ=Europe/London \
  -p 80:80 \
  -v </path/to/smokeping/config>:/config \
  -v </path/to/smokeping/data>:/data \
  -v </path/to/smokeping/cache>:/cache \
  --restart unless-stopped \
  divyavanmahajan/smokeping


docker create \
  --name=slave \
  -h slave1
  -e PUID=1001 \
  -e PGID=1001 \
  -e TZ=Europe/London \
  -e NO_WEB=1
  -e SLAVE_SECRET=12345678
  -e MASTER_URL=http://master/smokeping/smokeping.cgi
  --restart unless-stopped \
  divyavanmahajan/smokeping

```

### docker split master and a slave
The master is split into masterping and masterweb. The container masterping - will collect the data. The container masterweb will show the web frontend. For this to work correctly, the two containers should share the config and data volumes.

```
docker create \
  --name=masterping \
  -e PUID=1001 \
  -e PGID=1001 \
  -e TZ=Europe/London \
  -e NO_WEB=1
  -v </path/to/smokeping/config>:/config \
  -v </path/to/smokeping/data>:/data \
  -v </path/to/smokeping/cache>:/cache \
  --restart unless-stopped \
  divyavanmahajan/smokeping

docker create \
  --name=masterweb \
  -e PUID=1001 \
  -e PGID=1001 \
  -e TZ=Europe/London \
  -e NO_PING=1
  -p 80:80 \
  -v </path/to/smokeping/config>:/config \
  -v </path/to/smokeping/data>:/data \
  -v </path/to/smokeping/cache>:/cache \
  --restart unless-stopped \
  divyavanmahajan/smokeping


docker create \
  --name=slave \
  -h slave1
  -e PUID=1001 \
  -e PGID=1001 \
  -e TZ=Europe/London \
  -e NO_WEB=1
  -e SLAVE_SECRET=12345678
  -e MASTER_URL=http://master/smokeping/smokeping.cgi
  --restart unless-stopped \
  divyavanmahajan/smokeping

```
### docker-compose - standalone example

```
---
version: "3.4"
services:
  smokeping:
    image: divyavanmahajan/smokeping
    container_name: smokeping
    environment:
      - PUID=1001
      - PGID=1001
      - TZ=Europe/London
    volumes:
      - </path/to/smokeping/config>:/config
      - </path/to/smokeping/cache>:/cache
      - </path/to/smokeping/data>:/data
    ports:
      - 80:80
    restart: unless-stopped
```

## Support Info 

* Shell access whilst the container is running: `docker exec -it smokeping /bin/bash`
* To monitor the logs of the container in realtime: `docker logs -f smokeping`
* container version number 
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' smokeping`
* image version number
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' divyavanmahajan/smokeping`

## Updating Info

Below are the instructions for updating containers:  
  
### Via Docker Run/Create
* Update the image: `docker pull divyavanmahajan/smokeping`
* Stop the running container: `docker stop smokeping`
* Delete the container: `docker rm smokeping`
* Recreate a new container with the same docker create parameters as instructed above (if mapped correctly to a host folder, your `/config` folder and settings will be preserved)
* Start the new container: `docker start smokeping`
* You can also remove the old dangling images: `docker image prune`

### Via Docker Compose
* Update the image: `docker-compose pull divyavanmahajan/smokeping`
* Let compose update containers as necessary: `docker-compose up -d`
* You can also remove the old dangling images: `docker image prune`
