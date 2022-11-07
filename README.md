z3status - drop-in replacement for i3status
---

z3status is an alternate status bar for the i3-wm window manager. It is written in Zig, and is mostly a toy to see what can be done with Zig.


### Features

`z3status` aims to support the same features that `i3status` incorporates. Below is a list of metrics `z3status` will include by default. Crossed out features are yet to be implemented.

* date and time
* one minute process load average 
* ~~memory used / memory available~~
* ~~partition space available~~
* ~~battery info (if available)~~
* ~~network information~~

### Build

```bash
$ git clone https://github.com/sleibrock/z3status && cd z3status
$ zig build -Drelease-small
```
