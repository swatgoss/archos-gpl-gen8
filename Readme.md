1) If you have this from github, you also need to get the kernel
   and place it into a folder named "linux":
```
git clone git@github.com:swatgoss/archos-gpl-gen8-kernel.git linux
```
2) To build, type "make" in the buildroot folder.

--- old instructions from http://dev.openaos.org/wiki/SettingUpMultiRootGen8
```
sudo apt-get install autoconf automake bison build-essential cmake flex gawk gperf intltool libbz2-dev libcap-dev libglib2.0-dev libxml-simple-perl libxml2-dev lzma m4 rpm subversion texinfo x11-xkb-utils xmlto zlib1g-dev ncurses-dev expect libtool libmpfr-dev libgmp3-dev libgphoto2-2-dev
```

```
git clone git@github.com:swatgoss/archos-gpl-gen8.git
git clone git@github.com:swatgoss/archos-gpl-gen8-kernel.git linux
make [kernel|dist]
```
