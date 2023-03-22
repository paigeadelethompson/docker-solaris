# Dockerized Solaris 
This is a dockerized SPARC Solaris 2.6 container which relies on QEMU's usermode networking and therefore requires no capabilities or additional privileges to work. This 
setup relies on no external volume mapping, and in theory it will work on a swarm.

# Setup 

- grab the [Solaris 2.6 CD Image](https://winworldpc.com/download/3e5ec395-3d18-c39a-11c3-a4e284a2c3a5) and extract the ISO to 
`iso/solaris-2.6.iso

- Run `docker-compose build`

You should now have a base image:
```
docker image ls
REPOSITORY                           TAG        IMAGE ID       CREATED          SIZE
qemu-sparc                           latest     08ec3475e3ec   23 minutes ago   1.89GB
...
```

- Add the ISO to it: 

- `docker-compose run -v $(pwd)/iso:/mnt/iso sol cp /mnt/iso/solaris-2.6.iso /qemu/iso`
- `docker-compose down`

You should now have two new volumes: 

```
 docker volume ls
DRIVER    VOLUME NAME
...
local     docker-solaris_disk
local     docker-solaris_iso
...
```
- Start the container in pre-flight mode: 

```
docker-compose up --no-start
Creating network "docker-solaris_default" with the default driver
Creating docker-solaris_sol_1 ... done
```

Now just switch to using the `docker` command instead of `docker-compose`

- Start the container: `docker start docker-solaris_sol_1`
- Attach to the container: `docker attach docker-solaris_sol_1`

When you attach to it the PROM prompt will be waiting, hit enter in case you don't see anything and it should accept a blank line and give you a `0 >` prompt.

- To detach from the docker container: `control-p-q`
- When attached, `control-a-c` will switch between the QEMU monitor and the serial line, by default it's switched to the serial line when it first starts

```
docker attach docker-solaris_sol_1
0 > QEMU 5.2.0 monitor - type 'help' for more information <-- preessed control-a-c to switch to qemu monitor
(qemu) info network
hub 0
 \ hub0port2: lance.0: index=0,type=nic,model=lance,macaddr=52:54:00:12:34:56
 \ port2: user0: index=0,type=user,net=10.0.0.0,restrict=off
 \ port1: socket0: index=0,type=socket,
(qemu) info usernet
Hub 0 (user0):
  Protocol[State]    FD  Source Address  Port   Dest. Address  Port RecvQ SendQ
(qemu) <---- pressed control-a-c to switch back to serial line
  ok
0 > read escape sequence <---- pressed control-p-q and detached from the container 
❯<----- bash prompt
```

## Installing Solaris
By default this thing will try to boo from the hard disk image, and if it can't it will drop back to the PROM.

- At the PROM boot prompt, type `boot cdrom:d -vs` and hit enter:

```
docker attach docker-solaris-master_sol_1

Probing SBus slot 3 offset 0
Probing SBus slot 4 offset 0
Probing SBus slot 5 offset 0
Invalid FCode start byte
CPUs: 1 x FMI,MB86904
UUID: 00000000-0000-0000-0000-000000000000
Welcome to OpenBIOS v1.1 built on May 4 2022 19:50
  Type 'help' for detailed information
Trying disk:a...
Trying disk...
Not a bootable ELF image
Not a bootable a.out image
No valid state has been set by load or init-program

0 > boot cdrom:d -vs Not a bootable ELF image
Loading a.out image...
Loaded 7680 bytes
entry point is 0x4000
bootpath: /iommu@0,10000000/sbus@0,10001000/espdma@5,8400000/esp@5,8800000/sd@2,0:d
switching to new context:
Size: 243560+176918+41926 Bytes
```
