#FROM debian:11.6
FROM debian:bullseye

RUN apt update && apt install rtl-433 curl -y && mkdir /etc/rtl_433
COPY runme.sh /root/runme.sh
