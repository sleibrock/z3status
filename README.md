z3status - drop-in replacement for i3status
---

z3status is an alternate status bar for the i3-wm window manager. It is written in Zig, and is mostly a toy to see what can be done with Zig.


### Features

`z3status` aims to support the same features that `i3status` incorporates. Below is a list of metrics `z3status` will include by default. Crossed out features are yet to be implemented.

* date and time
* one minute process load average 
* memory used / memory available
* ~~partition space available~~
* ~~battery info (if available)~~
* ~~network information~~

### Build

```bash
$ git clone https://github.com/sleibrock/z3status && cd z3status
$ zig build -Drelease-small
```

### Motivations

The goal was to achieve some minimum-viable-program of `i3status` by writing a complete Zig program. `i3status` depends on a *lot* of dynamic libraries, and this lends itself to how flexible `i3status` can become if you configure it properly. The following text is all linked libraries by `i3status`.

```bash
➜  ~ ldd $(which i3status)
	linux-vdso.so.1 (0x00007fff3e127000)
	libm.so.6 => /usr/lib/libm.so.6 (0x00007fab75c86000)
	libconfuse.so.2 => /usr/lib/libconfuse.so.2 (0x00007fab75c75000)
	libyajl.so.2 => /usr/lib/libyajl.so.2 (0x00007fab75c69000)
	libpulse.so.0 => /usr/lib/libpulse.so.0 (0x00007fab75c14000)
	libnl-genl-3.so.200 => /usr/lib/libnl-genl-3.so.200 (0x00007fab75c0b000)
	libnl-3.so.200 => /usr/lib/libnl-3.so.200 (0x00007fab75be7000)
	libasound.so.2 => /usr/lib/libasound.so.2 (0x00007fab75af7000)
	libpthread.so.0 => /usr/lib/libpthread.so.0 (0x00007fab75af2000)
	libc.so.6 => /usr/lib/libc.so.6 (0x00007fab7590b000)
	/lib64/ld-linux-x86-64.so.2 => /usr/lib64/ld-linux-x86-64.so.2 (0x00007fab75daf000)
	libpulsecommon-16.1.so => /usr/lib/pulseaudio/libpulsecommon-16.1.so (0x00007fab75884000)
	libdbus-1.so.3 => /usr/lib/libdbus-1.so.3 (0x00007fab75833000)
	libgcc_s.so.1 => /usr/lib/libgcc_s.so.1 (0x00007fab75811000)
	libsndfile.so.1 => /usr/lib/libsndfile.so.1 (0x00007fab7578b000)
	libxcb.so.1 => /usr/lib/libxcb.so.1 (0x00007fab75760000)
	libsystemd.so.0 => /usr/lib/libsystemd.so.0 (0x00007fab75684000)
	libasyncns.so.0 => /usr/lib/libasyncns.so.0 (0x00007fab7567c000)
	libvorbisenc.so.2 => /usr/lib/libvorbisenc.so.2 (0x00007fab755cf000)
	libFLAC.so.12 => /usr/lib/libFLAC.so.12 (0x00007fab7558c000)
	libopus.so.0 => /usr/lib/libopus.so.0 (0x00007fab75532000)
	libmpg123.so.0 => /usr/lib/libmpg123.so.0 (0x00007fab754d5000)
	libmp3lame.so.0 => /usr/lib/libmp3lame.so.0 (0x00007fab7545d000)
	libvorbis.so.0 => /usr/lib/libvorbis.so.0 (0x00007fab7542f000)
	libogg.so.0 => /usr/lib/libogg.so.0 (0x00007fab75422000)
	libXau.so.6 => /usr/lib/libXau.so.6 (0x00007fab7541d000)
	libXdmcp.so.6 => /usr/lib/libXdmcp.so.6 (0x00007fab75415000)
	libcap.so.2 => /usr/lib/libcap.so.2 (0x00007fab75409000)
	libgcrypt.so.20 => /usr/lib/libgcrypt.so.20 (0x00007fab752c1000)
	liblzma.so.5 => /usr/lib/liblzma.so.5 (0x00007fab7528e000)
	libzstd.so.1 => /usr/lib/libzstd.so.1 (0x00007fab751e3000)
	liblz4.so.1 => /usr/lib/liblz4.so.1 (0x00007fab751c1000)
	libgpg-error.so.0 => /usr/lib/libgpg-error.so.0 (0x00007fab7519b000)
```

Now some of these make sense (`libm`, `libc`, `libpthread`), but then you get weird things like... `libgpg-error`?

The flexibility of `i3status` is that it can be configured to show more than what it normally does by default, by adding a configuration to include these extended libraries. Showing your volume (`libalsa`, `libasound`, or `libpulsecommon`) exist to give your system the best compatibility in case you don't use a particular one. The media file libraries allow you to ... load media files? I guess? I'm shocked `libmpd` isn't here to interact with the `mpd` daemon, but oh well.

Naturally, you can't gauge a program based purely on it's dynamically-linked libraries; in fact, the performance of `i3status` is completely fine and has it's merits as it's been used for ages. It's byte-count isn't even that large, and it clocks in at a nice 105,280 bytes.

However, the code is rather dated and hard to read, as it's pure C language. Converting it to a Zig codebase allows for better porting and integration with the Zig build system. In some cases in the `i3status` code base there are even calls to `malloc()`, so my goal was to start learning and seeing how much of the code could be carried over, integrate with a generic `libc` ABI, remove memory allocations, and see how far I could get copying some basic functions over.

