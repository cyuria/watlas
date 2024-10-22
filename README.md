# The Atlas

The atlas is at heart a launcher program, like all the others. Where the atlas
shines is that it does much more than most launchers. The atlas is more of a
map (or atlas) of your system. It provides system status info (like you would
get with any status bar), application launching capabilities, custom
configurable "buttons" and even arbitrary shell command execution.

## Compiling Source

### Requirements

- The zig compiler (from master, i.e. at least v0.14.0)
- Python (at least version 3.9)

### Building

Simply run the following command anywhere in the project source.
```sh
zig build
```

The resulting executable should be under `zig-out/bin/watlas`.

For development purposes, it is also possible to execute the following to
automatically build and run the executable.
```sh
zig build run
```

### Installing

The `zig build` command actually installs the `watlas` binary by default,
however it's not to a very helpful location. Specify the location with the `-p`
flag like one of the following:
```sh
zig build -p ~/.local
sudo zig build -p /usr/local
```

> [!NOTE]
> This command will likely require elevated priveledges using sudo. If you
> don't trust the command (and rightfully so), you can just copy the resulting
> executable from `zig-out/bin` to whereever you want it to end up.

## Naming

Feel free to interchangably use any terms you wish to refer to the atlas/
watlas. Language evolves and the only thing that matters is that people know
what you are referring to.

The 'W' in watlas actually does have meaning, but deciphering that meaning is
left as an exercise to the reader.
