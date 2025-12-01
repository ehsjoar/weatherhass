# Weatherhass
This projects is ongoing so nothing really working yet. I am also working in
branches, so the main branch will be really useless till I have a first alpha
version.  

The device I am using is an RTL2832u

## To Do
Some high level stuff we will need to accomplish
* Identify where the RTL 433 device is on the USB BUS. I am thinking we can
drive a service from udev rules, and start the service from a UDEV ACTION
* Create a container that runs rtl 443. This container will be started as a
service by above UDEV ACTION
* Create another container that runs an MQTT BUS. I am thinking mosquitto.
