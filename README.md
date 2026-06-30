# flgreet

A Flutter based greeter inspired by [gtkgreet](https://git.sr.ht/~kennylevinsen/gtkgreet).


[![screenshot](https://github.com/AR-CADE/flgreet/blob/main/assets/flgreet.png?raw=true "flgreet")](https://github.com/AR-CADE/flgreet/blob/main/assets/flgreet.png?raw=true)

## Dependencies

- [greetd](https://sr.ht/~kennylevinsen/greetd/)

Build dependencies

- [flutter](https://docs.flutter.dev/install/)
- [gtk-layer-shell](https://github.com/wmww/gtk-layer-shell/)
- [gtkmm-3.0](https://github.com/GNOME/gtkmm/)

## Usage
```
flgreet: 1.0.0
Usage: flgreet [OPTION]...

 -h,  --help              print this help
 -m,  --multi-monitors    (true/false) specify whether multi monitors support should be enabled or disabled. 
                          (only takes effect when Layer Shell is enabled; enabled by default)
 -l,  --layer-shell       enable Layer Shell support
 -v,  --version           print version and exit
```

## Getting Started

See the [greetd](https://man.sr.ht/~kennylevinsen/greetd/) documentation.

then run:

 ```
    $ flutter build linux
 ```

install the `flgreet` bundle on your system,

 ```
    $ sudo cp -rfp build/linux/x64/release/bundle YOUR_PATH/flgreet 
 ```

then edit `/etc/greetd/config.toml`:
```
[terminal]
....

[default_session]
command = "cage -s -d -m last -- YOUR_PATH/flgreet/flgreet"
...
```

# note
- parts of UI template and tests are AI generated (grok)

- need permanant storage to re-hydrate your widget ? :

```
    $ GREETER_HOME_PATH=/home/greeter
    ## or GREETER_HOME_PATH=/etc/greetd/greeter

    $ sudo mkdir -p $GREETER_HOME_PATH 
    $ sudo mkdir -p $GREETER_HOME_PATH/.cache 
    $ sudo mkdir -p $GREETER_HOME_PATH/.config 
    $ sudo mkdir -p $GREETER_HOME_PATH/.icons
    $ sudo mkdir -p $GREETER_HOME_PATH/.local
    $ sudo mkdir -p $GREETER_HOME_PATH/.local/share
    ## you can now configure this user with custom icons, configs, etc...

    $ sudo chown -R greeter:greeter $GREETER_HOME_PATH
    $ sudo chmod -R 770 $GREETER_HOME_PATH
    $ sudo usermod -d $GREETER_HOME_PATH greeter
```

- GTK and C++ parts are inspired by [wf-shell](https://github.com/WayfireWM/wf-shell)

# contact
arm-cade@proton.me