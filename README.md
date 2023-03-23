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
Configuration device id QEMU version 1 machine id 32
Probing SBus slot 0 offset 0
Probing SBus slot 1 offset 0
Probing SBus slot 2 offset 0
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

0 > boot cdrom:d Not a bootable ELF image
Loading a.out image...
Loaded 7680 bytes
entry point is 0x4000
bootpath: /iommu@0,10000000/sbus@0,10001000/espdma@5,8400000/esp@5,8800000/sd@2,0:d
switching to new context:
SunOS Release 5.6 Version Generic_105181-05 [UNIX(R) System V Release 4.0]
Copyright (c) 1983-1997, Sun Microsystems, Inc.
WARNING: /iommu@0,10000000/sbus@0,10001000/espdma@5,8400000/esp@5,8800000/sd@0,0 (sd0):
	corrupt label - wrong magic number

Configuring devices...
fdintr: nobody sleeping (c0 0 0)
fdintr: nobody sleeping (c0 0 0)
The system is coming up.  Please wait.
...
Select a Language

 0) English
 1) German
 2) Spanish
 3) French
 4) Italian
 5) Swedish

? 0
Select a Locale

The locale you select on this screen becomes the default displayed
on your desktop after you reboot the system.  Selecting a locale
determines how online information is displayed for a specific
locale or region (for example, time, date, spelling, and monetary value.)

NOTE: The ASCII only option gives you the default 128-character set that
was available in previous releases.  If you do not need to send/receive
international correspondence where you need locale-specific alphabetic
characters (like accented or umlaut characters) the ASCII only set
is sufficient. Otherwise, you can select an ISO locale which contains
a 256-character set.  Selecting an ISO locale can cause a minor
performance degradation (in many cases, less than 5%).

 0) USA - English (ASCII only)         12) Lithuania
 1) Czech Republic                     13) Latvia
 2) Denmark                            14) Netherlands
 3) Greece                             15) Netherlands/Belgium
 4) Australia - English (ISO-8859-1)   16) Norway
 5) Canada - English (ISO-8859-1)      17) Poland
 6) Ireland - English ( 8 bit )        18) Portugal
 7) New Zealand - English ( 8 bit )    19) Portugal/Brazil
 8) UK - English (ISO-8859-1)          20) Russia
 9) USA - English (ISO-8859-1)         21) Finland
10) Estonia                            22) Turkey
11) Hungary                            23) Go Back to Previous Screen


Type a number and press Return or Enter [0]:
...
What type of terminal are you using?
 1) ANSI Standard CRT
 2) DEC VT52
 3) DEC VT100
 4) Heathkit 19
 5) Lear Siegler ADM31
 6) PC Console
 7) Sun Command Tool
 8) Sun Workstation
 9) Televideo 910
 10) Televideo 925
 11) Wyse Model 50
 12) X Terminal Emulator (xterms)
 13) Other
Type the number of your choice and press Return: 1
...
```

- If you're having trouble with the terminal, press `control-l` (line feed) at any time to redraw the screen

```
- The Solaris Installation Program ---------------------------------------------
  The Solaris installation program is divided into a series of short sections
  where you'll be prompted to provide information for the installation. At
  the end of each section, you'll be able to change the selections you've
  made before continuing.

  About navigation...
        - The mouse cannot be used
        - If your keyboard does not have function keys, or they do not
          respond, press ESC; the legend at the bottom of the screen
          will change to show the ESC keys to use for navigation.











--------------------------------------------------------------------------------    Esc-2_Continue    Esc-6_Help

```

- Hit `escape_key-2`
- Follow the rest of the installer
- IP address `10.0.0.2`
- domain: `localdomain`
- Nameserver (specify one) `dunno` for hostname (tab to the next field) specify `4.2.2.1` for DNS
- select yes system is part of a subnet
- Specify `255.255.240.0` 
- It will fail, specify `no` when prompted to enter new name service info
- Go through the installer until you get to the partitioner
- And it will drop you out to command line when it can't find a disk:
```

Exiting (caught signal 11)

Type suninstall to restart.
# format
...
format> type


AVAILABLE DRIVE TYPES:
        0. Auto configure
        1. Quantum ProDrive 80S
        2. Quantum ProDrive 105S
        3. CDC Wren IV 94171-344
        4. SUN0104
        5. SUN0207
        6. SUN0327
        7. SUN0340
        8. SUN0424
        9. SUN0535
        10. SUN0669
        11. SUN1.0G
        12. SUN1.05
        13. SUN1.3G
        14. SUN2.1G
        15. SUN2.9G
        16. other
Specify disk type (enter its number)[15]:

```
- Save and quit
- Run `suninstall`
- And the install begins
```
Preparing system for Solaris install

Configuring disk (c0t0d0)
        - Creating Solaris disk label (VTOC)

Creating and checking UFS file systems
        - Creating / (c0t0d0s0)
        - Creating /usr/openwin (c0t0d0s1)
        - Creating /var (c0t0d0s3)
...
     Solaris Initial Install


            MBytes Installed:     0.18
18          MBytes Remaining:   419.36

          Installing: TWS uoshX Window System & Graphics Runtime Library Links
                              in /usr/lib



          |
|                     |           |           |           |           |
          0          20          40          60          80         100

...
Solaris 2.6 software installation succeeded

Customizing system files
        - Mount points table (/etc/vfstab)
        - Network host addresses (/etc/hosts)

Customizing system devices
        - Physical devices (/devices)
fdintr: nobody sleeping (c0 0 0)
fdintr: nobody sleeping (c0 0 0)
        - Logical devices (/dev)

Installing boot information
        - Installing boot blocks (c0t0d0s0)

Installation log location
        - /a/var/sadm/system/logs/install_log (before reboot)
        - /var/sadm/system/logs/install_log (after reboot)

Installation complete
Executing SolStart postinstall phase...
Executing finish script "patch_finish"...

Checking installed packages and patches...
QEMU 5.2.0 monitor - type 'help' for more information
(qemu) info registers
pc: f00645b0  npc: f00645b4
%g0-7: 00000000 ef6c5b2c 00000000 0000040d 000010e0 00000000 00000000 00000000
%o0-7: 00050c18 00000000 00000003 0009a7f0 0009269c 00000003 efffe508 00025bec
%l0-7: 04000081 ef6865a8 ef6865ac 00000000 00000000 0000040d 000010e0 ef6c5b2c
%i0-7: 00094460 0005bfdc 00000000 0a000000 00000000 0004e6cc efffe260 ef686424
%f00:  ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
%f08:  ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
%f16:  ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
%f24:  ffffffffffffffff ffffffffffffffff ffffffffffffffff 0000000000000000
psr: 04400081 (icc: -Z-- SPE: S--) wim: 00000001
fsr: 00000000 y: 00000000

(qemu) info registers
pc: 0002571c  npc: 00025720
%g0-7: 00000000 0004d400 00000000 18655444 7a476a38 00000000 00000000 00000000
%o0-7: 0009a7f0 00000001 00000001 000a35c8 00000000 00008024 efffe008 00025714
%l0-7: 00000050 00000000 00000000 00000000 000a4cf8 00000000 00000000 00000000
%i0-7: 0009b290 0004e6f4 0004d6a6 0004d660 000a35c8 00000000 efffe098 00024d50
%f00:  ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
%f08:  ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
%f16:  ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
%f24:  ffffffffffffffff ffffffffffffffff ffffffffffffffff 0000000000000000
psr: 04400026 (icc: -Z-- SPE: --E) wim: 00000080
fsr: 00000000 y: 00000000

(qemu)
Verifying sufficient filesystem capacity (dry run method)...
Installing patch packages...
Patch number 105570-01 has been successfully installed.
See /a/var/sadm/patch/105570-01/log for details

Patch packages installed:
  SUNWrtvc
  SUNWrtvcl

Checking installed packages and patches...
Verifying sufficient filesystem capacity (dry run method)...
Installing patch packages...


Patch number 105633-05 has been successfully installed.
See /a/var/sadm/patch/105633-05/log for details

Patch packages installed:
  SUNWxwcft
  SUNWxwfnt
  SUNWxwplt
  SUNWxwslb


Checking installed packages and patches...
Executing prepatch script...
Verifying sufficient filesystem capacity (dry run method)...
Installing patch packages...

Patch number 105654-03 has been successfully installed.
See /a/var/sadm/patch/105654-03/log for details

Patch packages installed:
  SUNWcsr


Checking installed packages and patches...
Executing prepatch script...
Verifying sufficient filesystem capacity (dry run method)...
Installing patch packages...
...

```

This part just takes forever, why the disc shipped with patches RTM that weren't already applied is beyond me, but it needs to do it, and then it will auto-reboot:

```
Executing JumpStart postinstall phase...

The begin script log 'begin.log'
is located in /var/sadm/system/logs after reboot.

The finish script log 'finish.log'
is located in /var/sadm/system/logs after reboot.

Mar 22 17:11:04 rpcbind: rpcbind terminating on signal.
syncing file systems... done
rebooting...
rebooting ()
Configuration device id QEMU version 1 machine id 32
Probing SBus slot 0 offset 0
Probing SBus slot 1 offset 0
Probing SBus slot 2 offset 0
Probing SBus slot 3 offset 0
Probing SBus slot 4 offset 0
Probing SBus slot 5 offset 0
Invalid FCode start byte
CPUs: 1 x FMI,MB86904
UUID: 00000000-0000-0000-0000-000000000000
Welcome to OpenBIOS v1.1 built on May 4 2022 19:50
  Type 'help' for detailed information
Trying disk:a...
Not a bootable ELF image
Loading a.out image...
Loaded 7680 bytes
entry point is 0x4000
bootpath: /iommu@0,10000000/sbus@0,10001000/espdma@5,8400000/esp@5,8800000/sd@0,0:a
switching to new context:
SunOS Release 5.6 Version Generic_105181-05 [UNIX(R) System V Release 4.0]
Copyright (c) 1983-1997, Sun Microsystems, Inc.
Hostname: solaris
Configuring the /devices directory
fdintr: nobody sleeping (c0 0 0)
fdintr: nobody sleeping (c0 0 0)
Configuring the /dev directory
Configuring the /dev directory (compatibility devices)
The system is coming up.  Please wait.
checking ufs filesystems
/dev/rdsk/c0t0d0s1: is clean.
/dev/rdsk/c0t0d0s5: is clean.
/dev/rdsk/c0t0d0s7: is clean.
Configuring network interface addresses: le0
RPC: Timed out
NIS domainname is localdomain
...
```

and then after a bit you will be prompted to change the password: 
```
On this screen you can create a root password.

A root password can contain any number of characters, but only the first eight
characters in the password are significant. (For example, if you create
`a1b2c3d4e5f6' as your root password, you can use `a1b2c3d4' to gain root
access.)

You will be prompted to type the root password twice; for security, the passwordwill not be displayed on the screen as you type it.

> If you do not want a root password, press RETURN twice.

Root password:


Press Return to continue.
```
I set mine to `cheese`

```
System identification is completed.
Setting netmask of le0 to 255.255.240.0
Setting default interface for multicast: add net 224.0.0.0: gateway solaris
syslog service starting.
passwd.org_dir: Error in accessing NIS+ cold start file... is NIS+ installed?.
group.org_dir: Error in accessing NIS+ cold start file... is NIS+ installed?.
hosts.org_dir: Error in accessing NIS+ cold start file... is NIS+ installed?.
Print services started.
volume management starting.
The system is ready.

solaris console login: root
Password:cheese
Mar 22 20:14:54 solaris login: ROOT LOGIN /dev/console
Sun Microsystems Inc.   SunOS 5.6       Generic August 1997
# ifconfig -a
lo0: flags=849<UP,LOOPBACK,RUNNING,MULTICAST> mtu 8232
        inet 127.0.0.1 netmask ff000000
le0: flags=863<UP,BROADCAST,NOTRAILERS,RUNNING,MULTICAST> mtu 1500
        inet 10.0.0.2 netmask fffff000 broadcast 10.0.15.255
        ether 52:54:0:12:34:56
# ping 10.0.0.1
10.0.0.1 is alive
# route add default 10.0.0.1
add net default: gateway 10.0.0.1
# 4.2.2.1
4.2.2.1 is alive
```

# Problems

- Running on a Mac M1 at the moment doesn't work

