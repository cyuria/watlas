# Undocumented Wayland Shit

There are a few pretty core parts of wayland which just aren't documented
anywhere in any kind of reasonable manner. In no particular order, here they
are:

## ID Binding

This is particularly relevant to binding globals from the `wl_registry`.

If a new id is specified (by a `new_id` field in a request), and there is no
interface specified in the xml argument, then the `new_id` is not just a u32,
but also a string with the interface and an int for the version.

For example, the `wl_registry::bind` request has the following xml definition:
```xml
<request name="bind">
  <description summary="bind an object to the display">
Binds a new, client-created object to the server using the
specified name as the identifier.
  </description>
  <arg name="name" type="uint" summary="unique numeric name of the object"/>
  <arg name="id" type="new_id" summary="bounded object"/>
</request>
```

In the ID field, there's no specified interface. That means a corresponding C
struct for that request would not look like this:
```c
struct {
    uint32_t name;
    uint32_t id;
}
```
But instead something like this:
```c
struct {
    uint32_t name;
    uint32_t interface_len;
    char interface[interface_len];
    uint32_t version;
    uint32_t id;
}
```

## The first Configure Event

Before a configure event is given, you first need to call `wl_surface::commit`.
I have no idea why this is the case, but it is.
