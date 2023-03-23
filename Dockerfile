FROM debian:latest

ENV GRAPHICS tcx

ENV DEFAULT_DISK_SIZE 4.2G

ENV DISK_VENDOR SEAGATE

ENV DISK_MODEL ST15230N

ENV DISK_VERSION 1.0

ENV CD_VENDOR SUN

ENV CD_MODEL SS600MP

ENV CD_VERSION 1.0

ENV USER_NET 10.0.0.0/20

ENV USER_NET_GW 10.0.0.1

ENV BOOT c

ENV MACHINE_TYPE SS-5

ENV CD_IMAGE /qemu/iso/blank.iso

ENV DISK_IMAGE /qemu/disk/default_disk.qcow2

ENV MEM 128M

ENV SMP 1

ENV VNC_HOST 127.254.127.254:0

ENV SOCKET_NET listen=127.254.127.254:65534

ENV DEBIAN_FRONTEND noninteractive

ENV MAC "de:ad:de:01:02:03"

RUN apt-get update && apt-get -y install qemu-system-sparc mkisofs qemu-utils

RUN groupadd -g 16384 docker-qemu

RUN useradd -u 32768 -g docker-qemu docker-qemu

RUN mkdir -p /qemu/disk

RUN mkdir -p /qemu/iso

RUN mkdir /empty

RUN truncate -s 1M /empty/.empty

RUN mkisofs -o ${CD_IMAGE} /empty

RUN rm -rf /empty

RUN qemu-img create -f qcow2 ${DISK_IMAGE} ${DEFAULT_DISK_SIZE}

RUN chown -R docker-qemu:docker-qemu /qemu

USER docker-qemu

VOLUME /qemu/disk

VOLUME /qemu/iso

WORKDIR /qemu

CMD qemu-system-sparc                                                                                             \
 -nodefaults                                                                                                      \
 -M ${MACHINE_TYPE}                                                                                               \
 -m ${MEM}                                                                                                        \
 -serial mon:stdio                                                                                                \
 -smp ${SMP}                                                                                                      \
 -device scsi-hd,scsi-id=0,drive=hd1,vendor="${DISK_VENDOR}",product="${DISK_MODEL}",ver="${DISK_VERSION}"        \
 -drive file=${DISK_IMAGE},media=disk,format=qcow2,if=none,id=hd1                                                 \
 -device scsi-cd,scsi-id=2,drive=cd1,vendor="${CD_VENDOR}",product="${CD_MODEL}",ver="${DISK_VERSION}"            \
 -drive file=${CD_IMAGE},media=cdrom,if=none,id=cd1                                                               \
 -netdev socket,id=socket0,${SOCKET_NET}                                                                          \
 -netdev hubport,hubid=0,id=port1,netdev=socket0                                                                  \
 -net nic,model=lance                                                                                             \
 -netdev user,id=user0,net=${USER_NET},host=${USER_NET_GW}                                                        \
 -netdev hubport,hubid=0,id=port2,netdev=user0                                                                    \
 -vga ${GRAPHICS}                                                                                                 \
 -display vnc=${VNC_HOST}
