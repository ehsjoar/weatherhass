# Weatherhass
## Introduction
This project came about as part of the SUSE [Hack Week](https://hackweek.opensuse.org/)  
I am currently not addressing the MQTT server. You can also set that up as a
container but there are many ways of getting an MQTT server up and running,
including just installing one in Home Assistant. 

## Project Definition
Integration of Home Assistant with weather stations using radio to emit weather
data on 433.92 MHz. While some potential automation examples that can come out
of this are highlighted, this project will not actually deal with those examples
but rather with the integration between the weather station and Home Assistant.
The idea is to use a radio USB dongle (RTL2832), the rtl-433 software, and an
MQTT bus to facilitate the introduction of the metrics into Home Assistant. Home
Assistant already has integration for consuming metrics off an MQTT bus.

## Assumptions
As I only had a couple of days to do this I didn't have time to script the whole
installation. The files that are in this project have some assumptions in them.
It would be necessary to make change to them to fit other environments and
setups that I had during this project. Here are some stuff that needs to be
changed:  
* Containers/rtl_433/runme.sh - update with MQTT server's hostname/IP, port, and
  the needed credentials. You can also make changes to your topics here but what
  is there now is working in Home Assistant
* Containers/rtl_433/rtl_433.conf - This one I have pretty much left alone and
  just used the one provided by the package maintainer in Debian. It works. If you
  understand the parameters feel free to change
* Containers/rtl_433/Dockerfile - This one should be changed to latest Debian. I
  had previous experience with rtl-433 on Bullseye, so that is why I left it
  like that. I intend to test with Trixie too
* Containers/rtl_433/docker-compose-rtl433.yml - Here I have made assumptions on
  where podman ends up, as well as volumes. Please adjust to your environment.
  Note the devices section. This one is important as we are passing an environment
  variable to the container this way. This environment variable is the host device
  of the RTL2832
* udev-rules/10-rtl-sdr.rules - Leave as is unless you know what you are doing
* Services/docker-rtl433@.service - Assumptions on where podman-compose is, and
  what service WorkingDirectory you will be using. Can all be changed. Also, as
  for any service file, dependencies can be a bit dependent on what distro you
  are running

## How it all fits together
The idea here is that the following happens at either system start up or when
the RTL2832 is introduced to the system:
* The udev rule 10-rtl-sdr.rule matches the device, creates a symlink
  /dev/RTL2832U. Note that this symlink cannot be passed into a container, but it
  is used by the service file (at least that is my understanding). 
* The udev subsystem creates and starts the service
  docker-rtl433@-dev-bus-usb-$env{BUSNUM}-$env{DEVNUM}.service (e.g.
  docker-rtl433@-dev-bus-usb-001-002.service). Note that the service has a BindsTo
  parameter that is used to identify the udev device and that the real device path
  is in the "%I" variable, which is part of the ExecStart call
* That service is using podman-compose and a compose file to (if needed) build
  the container, then start it. It will pass in the real device to the container.

## Installation
To start with it is a good idea to build the container, and try to run it
stand-alone without the udev and service integration. Just to make sure it
works. You will need to figure out where your USB dongle is hanging out, eg: 
```bash
$ lsusb | grep RTL2838
```
Once you have your container work in a stand-alone mode, you need to edit all
the files to match your environment (see Assumptions). Then:
* Copy the service file to /etc/systemd/system
* Create the directory for your container (e.g.
/usr/local/Podman/DockerCompose/rtl_433/) and copy over rtl_433.conf, runme.sh,
Dockerfile, and docker-compose-rtl433.yml there.
* Copy over 10-rtl-sdr.rules to /etc/udev/rules.d/
* Reboot your server or reload udev and systemd

## Troubleshooting
To be added

## Output
If you have mosquitto tools (mosquitto-clients) installed you can run
mosquitto_sub and test that you are receiving your weather data:

```bash
jonas@suselaptop:~$ mosquitto_sub -h 192.168.2.100 --username <user> -P <password> -v -t sensors/#
sensors/Fineoffset-WH24/0/229/time 2025-12-03 08:39:09.502401
sensors/Fineoffset-WH24/0/229/protocol 78
sensors/Fineoffset-WH24/0/229/id 229
sensors/Fineoffset-WH24/0/229/battery_ok 1
sensors/Fineoffset-WH24/0/229/temperature_F 53.42
sensors/Fineoffset-WH24/0/229/humidity 58
sensors/Fineoffset-WH24/0/229/wind_dir_deg 285
sensors/Fineoffset-WH24/0/229/wind_avg_m_s 1.4
sensors/Fineoffset-WH24/0/229/wind_max_m_s 2.24
sensors/Fineoffset-WH24/0/229/rain_in 73.34631
sensors/Fineoffset-WH24/0/229/uv 62
sensors/Fineoffset-WH24/0/229/uvi 0
sensors/Fineoffset-WH24/0/229/light_lux 7858.0
sensors/Fineoffset-WH24/0/229/mic CRC
```

## Setup in Home Assistant
To be added
