# Way2 Documentation

A basic program might look as follows:

```zig
const way2 = @import("src/way2.zig");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};

var client = way2.Client.init(gpa.allocator());
try client.connect();
defer client.disconnect();

var window = way2.Window.init(&client);
try window.open(
    .{ 800, 600 },
    .{},
);
defer window.close();

drawSomeStuff();

try window.present();

try client.listen();
```

## Window

A wrapper around `wl_surface` and surface role protocols like `xdg_shell` and
`wlr_layer_shell`.

This, at a high level, handles the creation, deletion, etc of windows.

Most user code will be interacting with this struct.

### Open

```zig
pub fn open(
    self: *Window,
    size: @Vector(2, u32),
    options: struct {
        role: union(enum) {
            xdg: struct {
                fullscreen: enum { fullscreen, windowed } = .windowed,
                state: enum { default, maximised, minimised } = .default,
                min_size: ?@Vector(2, u32) = null,
                max_size: ?@Vector(2, u32) = null,
                decorations: enum { clientside, serverside } = .clientside,
            },
            layer: struct {
                layer: enum { background, bottom, top, overlay } = .top,
                margin: ?struct { top: u32 = 0, right: u32 = 0, bottom: u32 = 0, left: u32 = 0 } = null,
                keyboard_interactivity: bool = true,
            },
            fullscreen: struct {},
        } = .{ .xdg = .{} },
    },
) !void;
```

Opens a window. Provides a number of optional flags which control how the
window is opened.

#### Configuration and Options

The `role` union specifies window role specific options. The tag is used to
determine which shell protocol should be used and which role should be assigned
to the window.

Each sub field has its own dedicated options. Each of these is equipped with
sensible defaults.

#### Example

```zig
try window.open(
    .{ 800, 600 },
    .{
        .role = .{
            .wlr_layer = .{
                .layer = .overlay,
                .margin = .{ .left = 5 },
            }
        }
    },
);
```

#### Errors

```zig
error.SystemFdQuotaExceeded,
error.ProcessFdQuotaExceeded,
```

If the process or the system file descriptor quota has been exceeded while
creating an anonymous file for memory mapping.

```zig
error.InputOutput
```

If an IO error is raised during file buffer operations.

```zig
error.WaylandConnection;
```

If there is a connection error.

```zig
error.WaylandDisconnected
```

If there is a connection error. Whenever this is returned, the client has also
been disconnected.

#### Panics

May panic if one of the following is encountered.
- `error.MemoryMappingNotSupported`
- `error.LockedMemoryLimitExceeded`
- `error.OutOfMemory`
- `error.NetworkSubsystemFailed`
- `error.SystemResources`
- `error.Unexpected`

### Close

```zig
pub fn close(
    self: *Window,
) void;
```

Closes the window.

This has not yet been implemented.

### Damage

```zig
pub fn damage(
    self: *Window,
    region: @Vector(4, i32),
)
```

Marks a region of the window as "damaged", meaning the content of that region
has changed and needs to be updated by the compositor.

This has not been implemented.

### Present

```zig
pub fn present(
    self: *Window,
) !void;
```

Present a rendered frame to the compositor.

Listens until `self.frame.time.done` is true. This may cause the process to
block. If you do not want this behaviour, construct your own loop and do not
call `Window.present()` until either `self.frame.time.done` has been updated or
the blocking behaviour is wanted.

#### Example

```zig
try window.present();
```

#### Errors

```zig
error.WaylandConnection;
```

If there is a connection error.

```zig
error.WaylandDisconnected
```

If there is a connection error. Whenever this is returned, the client has also
been disconnected.

```zig
error.InvalidWaylandMessage
```

If an invalid wayland message has been received.

This may indicate an incorrect registry setup (such as the wrong interface
being bound to an object).

#### Panics

May panic if one of the following is encountered.
- `error.NetworkSubsystemFailed`
- `error.OutOfMemory`
- `error.SystemResources`
- `error.Unexpected`

### Surface

```zig
const type2 = @import("type2.zig");
pub fn surface(
    self: Window,
) type2.surface;
```

Get a reference to the frame/surface of the window.

This reference is subject to change upon a surface reconfigure, which may
happen any time `Client.listen()` is called.

Good code will assume any wayland calls will invalidate the reference.

This function does no computation and simply exists as an alias to
`window.frame.buffer.surface`.

#### Example

```zig
_ = window.surface();
```

#### Panics

This function does not panic.

## Client

An interface for basic wayland wire protocol management. It is not a direct
libwayland replacement, as `Client` also manages wayland object events via
callbacks and provides a map for all available global objects.

Create with `Client.init()` and destroy with `Client.deinit()`.

### Connect

```zig
pub fn connect(
    self: *Client,
) !void;
```

Initiates a connection with the wayland compositor. Call this before anything
else.

#### Example

```zig
var client = Client.init(gpa.allocator());
try client.connect();
defer client.disconnect();
```

#### Errors

```zig
error.WaylandConnection;
```

If there is a connection error.

```zig
error.MissingEnv;
```

If a required environment variable is missing.

#### Panics

May panic if one of the following is encountered.
- `error.OutOfMemory`
- `error.SystemResources`
- `error.Unexpected`

### Send

```zig
pub fn send(
    self: *Client,
    object: u32,
    request: anytype,
) !void;
```

Make a wayland request.

#### Example

```zig
// Protocol file generated by scanner.zig
const wayland = @import("protocols/wayland.zig");

try client.send(1, wayland.display.rq{ .get_registry = .{ .registry = 2 } });
```

#### Errors

```zig
error.WaylandConnection;
```

If there is a connection error.

```zig
error.WaylandDisconnected
```

If there is a connection error. Whenever this is returned, the client has also
been disconnected.

#### Panics

May panic if one of the following is encountered.
- `error.OutOfMemory`
- `error.SystemResources`
- `error.Unexpected`

### SendFd

```zig
pub fn sendFd(
    self: *Client,
    object: u32,
    request: anytype,
    fd: std.posix.fd_t,
) !void;
```

Make a wayland request with a file descriptor passed in the ancillary message
data.

#### Example

```zig
// Protocol file generated by scanner.zig
const wayland = @import("protocols/wayland.zig");

try self.client.sendFd(
    wl_shm,
    wayland.shm.rq{ .create_pool = .{
        .id = wl_shm_pool,
        .size = pool_length,
    } },
    shared_memory_fd,
);
```

#### Errors

```zig
error.WaylandConnection;
```

If there is a connection error.

```zig
error.WaylandDisconnected
```

If there is a connection error. Whenever this is returned, the client has also
been disconnected.

#### Panics

May panic if one of the following is encountered.
- `error.OutOfMemory`
- `error.SystemResources`
- `error.Unexpected`

### Recv

```zig
pub fn recv(
    self: *Client,
) !void;
```

Receives and handles a single wayland message. Typically used within a loop to
handle multiple messages at once.

#### Example

```zig
try client.recv();
```

#### Errors

```zig
error.WaylandConnection;
```

If there is a connection error.

```zig
error.WaylandDisconnected
```

If there is a connection error. Whenever this is returned, the client has also
been disconnected.

```zig
error.InvalidWaylandMessage
```

If an invalid wayland message has been received.

This may indicate an incorrect registry setup (such as the wrong interface
being bound to an object).

#### Panics

May panic if one of the following is encountered.
- `error.OutOfMemory`
- `error.SystemResources`
- `error.Unexpected`

### Listen

Listen and handle all incoming wayland events.

#### Example

```zig
try client.listen();
```

#### Errors

```zig
error.WaylandConnection;
```

If there is a connection error.

```zig
error.WaylandDisconnected
```

If there is a connection error. Whenever this is returned, the client has also
been disconnected.

```zig
error.InvalidWaylandMessage
```

If an invalid wayland message has been received.

This may indicate an incorrect registry setup (such as the wrong interface
being bound to an object).

#### Panics

May panic if one of the following is encountered.
- `error.NetworkSubsystemFailed`
- `error.OutOfMemory`
- `error.SystemResources`
- `error.Unexpected`

### Bind

```zig
const wl = @import("prototypes/proto.zig");

pub fn bind(
    self: *Client,
    interface: wl.Interface,
) u32;
```

Bind a new wayland object. Returns the ID of the newly created object.

#### Example

```zig
const my_callback = client.bind(.wl_callback);
```

#### Panics

May panic if one of the following is encountered.
- `error.OutOfMemory`

### Invalidate

```zig
pub fn invalidate(
    self: *Client,
    object: u32,
) void;
```

Invalidates a wayland object locally.

Use this function to signify an object can be safely deleted. The object number
will not be reused until `wl_display::delete_id` is called.

Sets the object's corresponding interface to `.invalid`.

#### Example

```zig
client.invalidate(callback_object);
```

#### Panics

This function does not panic.

### Misc

Some common operations don't have associated functions.

#### Register Event Handlers

Register an event handler with the receiver.

```zig
client.handlers.items[1].wl_display.set(.wl_error, .{
    .context = &myData,
    .call = @ptrCast(&myFunc),
});
```

The function must be compatible with the following signature:
```zig
fn (*anyopaque, u32, enum {}, []const u8) void;
```

Where the enum is replaced with the event enum for the interface.

For example, a matching function callback for an event of an `xdg_wm_base`
object could be:

```zig
fn myFunc(
    context: *@TypeOf(myData),
    object: u32,
    opcode: xdg_shell.wm_base.event, // or whatever other interface
    body: []const u8,
) void;
```

The wayland event stored is contained in serialised form in the `body` field.

It is deserialisable with the `deserialiseStruct()` function as follows:

```zig
const event = deserialiseStruct(xdg_shell.wm_base.ev.ping, body);
```

Note that event handlers CANNOT return errors.

#### Binding a Global Object

Since globals are managed by the `Client`, it is possible to obtain all
relevant components as follows:

```zig
const wl_compositor = client.globals.objects.get("wl_compositor");
_ = wl_compositor.name;
_ = wl_compositor.string;
_ = wl_compositor.version;
```

These can then be used in the binding process:

```zig
const wayland = @import("protocols/wayland.zig");

compositor_object = client.bind(.wl_compositor);
try client.send(
    Client.wl_registry,
    wayland.registry.rq{
        .bind = .{
            .id = compositor_object,
            .interface = wl_compositor.string,
            .version = wl_compositor.version,
            .name = wl_compositor.name,
        },
    },
);
```

Note that the requirement of the interface string is an undocumented "feature"
of the wayland wire protocol.

Since `client.globals.objects` is a `std.StringHashMap`, all the other
functions, like `.contains()` also work.

## Index

A separated component of [`Client`](#Client) which stores and manages global
objects.

Create with `Index.init()` and destroy with `Index.deinit()`.

### objects

A string hash map with interface name to object correlations.

Modifying this map should be done with care.

```zig
_ = Index{}.objects.contains("wl_compositor");
_ = Index{}.objects.get("xdg_wm_base").?;
```

### names

A map of object names to the name of the corresponding interface which can be
looked up in [`objects`](#objects).

```zig
Index{}.names.get(name);
```

## Buffer

A region of memory used for various buffer purposes.

This is memory mapped to an anonymous shared file.

Create with `Buffer.init()` and destroy with `Buffer.deinit()`.

#### Resize

Resizes the region to the given size.

#### Shm

The file descriptor to which the buffer is memory mapped.

#### Pool

The slice of memory to which the buffer is memory mapped.

This may change upon a call to `Buffer.resize()`.

## Scanner

Way2 includes a `scanner.py` file. Run this file to generate zig structs and
other relevant source code required for way2 from any wayland protocol xml
files.

