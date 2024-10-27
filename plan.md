# Way2 Planning

## Available Objects

### Client

Contains basic wayland data like the registry.

#### Connect

Initiates a connection with the wayland compositor.

#### Send

Sends a message.

#### Recv

Private?

Receives a message.

Optionally other functions which may introduce other features such as a timeout
or quantity of messages to receive.

#### Listen

Listen and handle all wayland events.

#### Bind

Bind a new wayland object.

#### Register

Register an event handler with the receiver.

### Index

Part of the wayland client which is separated. Used for managing globals.

#### Bind

Bind a global

#### Unbind

Unbind a global

#### Has

Use the following:

```zig
Index{}.objects.contains(interface);
```

#### Get

Use the following:

```zig
Index{}.objects.get(interface);
```

### Buffer

A region of memory used for various buffer purposes.

This is memory mapped to an anonymous shared file.

#### Map

Creates the region.

#### Resize

Resizes the region.

#### Unlink

Unlinks (or frees) the memory.

### Framebuffer

A portion of a buffer which represents pixel data.

#### Prepare

Creates a wayland object for the framebuffer.

#### Attach

Attaches the framebuffer to a surface.

### Surface

A surface which is closely tied to the `wl_surface` object.

### Window

Tagged union for role objects.

```zig
const Role = union(enum) {
    none: void, // ? is this necessary
    xdg_shell: xdg_shell,
    wlr_layer_shell: wlr_layer_shell,
    ...
};
```

See also alternative function selection below.

Can also be called `Shell`.

A wrapper around surface role protocols like `xdg_shell` and `wlr_layer_shell`.

This, at a high level, handles the creation, deletion, etc of windows and
surfaces.

#### Function Selection

Quite a few of the member functions will require different handling in some
cases. One solution is the above mentioned tagged union.

Another solution is to hold a series of function pointers which get assigned at
runtime when `Window.open()` is called.

#### Open

Opens a window. Provides a number of optional flags which control how the
window is opened.

#### xdg_shell

Opens a window using the `xdg_shell` protocol.

Controls an `xdg_surface` wayland object.

#### layer_shell

Opens a window using the `wlr_layer_shell` protocol.

Controls a `wlr_layer_surface` wayland object.

#### Frame

Handles generating a new frame.

#### Queue

An event queue.
