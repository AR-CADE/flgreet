# flgreet

A Flutter based greeter inspired by [gtkgreet](https://git.sr.ht/~kennylevinsen/gtkgreet).


[![screenshot](./assets/flgreet.png?raw=true "flgreet")](./assets/flgreet.png?raw=true "flgreet")

## Dependencies

- [greetd](https://sr.ht/~kennylevinsen/greetd/)

Build dependencies

- [flutter](https://docs.flutter.dev/install/)
- [gtk-layer-shell](https://github.com/wmww/gtk-layer-shell/)
- [gtkmm-3.0](https://github.com/GNOME/gtkmm/)

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
command = "cage -s -d -- YOUR_PATH/flgreet/flgreet"
...
```

# Need permanant storage to re-hydrate your widget ?

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

# note
parts of UI template and tests are AI generated (grok)


# contact
arm-cade@proton.me