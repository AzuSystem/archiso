# AzuOS

## What is AzuOS?
AzuOS is an Arch-based operating system, that features its own desktop made on top of Openbox.

## What is this repository for?
This repository hosts the archiso configuration and files for building an AzuOS system.

## Build instructions

### Prerequisites
To build the archiso-config, you need to have a system running **Arch Linux** (or derivatives).

The following packages are ALSO required for building:
- git
- xorriso
- arch-install-scripts
- dosfstools
- erofs-utils
- libburn
- libisoburn
- libisofs
- mtools
- squashfs-tools
- archiso

You can install these by running the following command with administrative permissions:

```bash
pacman -S git xorriso arch-install-scripts dosfstools erofs-utils libburn libisoburn libisofs mtools squashfs-tools archiso
```

### Cloning repository
Next, clone this repository by running the following in the Arch system:

```bash
git clone https://github.com/AzuSystem/archiso
```

### Build system
Change directory into the newly cloned repository, make an "out" directory in it and start building the config (with administrative permissions again):

```bash
cd archiso; mkdir out; mkarchiso -v -w /tmp/archiso-tmp -o ./out ./
```

In a more understandable format:
```bash
cd archiso
mkdir out
mkarchiso -v -w /tmp/archiso-tmp -o /path/to/cloned-repo/out /path/to/cloned-repo/
```

The output image should then be inside of the "out" directory.