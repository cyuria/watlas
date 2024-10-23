#!/usr/bin/env python3

""" ZigScanner
A python script to enumerate wayland protocol requests and events
"""

from pathlib import Path
from subprocess import check_output
from sys import argv
from xml.etree import ElementTree as ET
from re import match

destination = Path(__file__).parent / "protocols"

substitutions = {
    "async",
    "const",
    "error",
    "export",
    "struct",
    "var",
    "type",
    "test",
}

typesubstitutions = {
    "array": "types.Array",
    "int": "i32",
    "fixed": "f64",
    "new_id": "u32",
    "object": "u32",
    "string": "types.String",
    "uint": "u32",
}

definitions = """
pub const String = [:0]u8;
pub const Array = []u32;
"""

def commonPrefix(strs: list[str]):
    if not strs:
        return ""

    for i, letters in enumerate(zip(*strs)):
        if len(set(letters)) > 1:
            return strs[0][:i]
    return min(strs, key=len)

def zigFormat(source: str) -> str:
    return check_output(
        ['zig', 'fmt', '--stdin'],
        input=source,
        text=True
    )

def rename(name: str, namespace: str) -> str:
    prefix = ''
    if name in substitutions or not name[0].isalpha():
        prefix = f"{namespace}_"
    return f"{prefix}{name}"

def argument(element: ET.Element) -> str:
    name = element.attrib['name']
    tp = element.attrib['type']
    if tp == "fd":
        return ''
    result = f"{name}: {typesubstitutions[tp]},"
    if tp == "new_id" and "interface" not in element.attrib:
        result = '\n'.join([
            f"interface: {typesubstitutions['string']},",
            f"version: {typesubstitutions['uint']},",
            result,
        ])
    return result

def method(element: ET.Element) -> str:
    args = [child for child in element if child.tag == 'arg']
    if not args:
        return 'void'
    return f"""extern struct {{
        {'\n'.join(argument(arg) for arg in args)}
    }}"""

def enumEntry(element: ET.Element, namespace) -> str:
    name = rename(element.attrib['name'], namespace)
    value = element.attrib['value']
    return f"{name} = {value},"

def enum(element: ET.Element, namespace: str) -> str:
    entries = [child for child in element if child.tag == 'entry']
    return f"""enum(u32) {{
        {'\n'.join(enumEntry(e, namespace) for e in entries)}
    }}"""

def interface(element: ET.Element, namespace: str) -> str:
    name = element.attrib['name']
    if not name.startswith(f'{namespace}_'):
        raise Exception("interface does not start with namespace")
    name = name.removeprefix(f'{namespace}_')

    requests = [
        child
        for child in element
        if child.tag == 'request'
    ]
    events = [
        child
        for child in element
        if child.tag == 'event'
    ]
    enums = [
        child
        for child in element
        if child.tag == 'enum'
    ]
    return f"""
        pub const {name} = struct {{
            pub const request = enum {{
                {'\n'.join(
                    f'{rename(r.attrib['name'], namespace)},'
                    for r in requests
                )}
            }};

            pub const event = enum {{
                {'\n'.join(
                    f'{rename(e.attrib['name'], namespace)},'
                    for e in events
                )}
            }};

            pub const rq = union(request) {{
                { '\n'.join(
                    f'{
                        rename(r.attrib['name'], namespace)
                    }: {
                        method(r)
                    },'
                    for r in requests
                ) }
            }};

            pub const ev = struct {{
                { '\n'.join(
                    f'pub const {
                        rename(e.attrib['name'], namespace)
                    } = {
                        method(e)
                    };'
                    for e in events
                ) }
            }};

            { '\n'.join(
                f'pub const {
                    rename(e.attrib['name'], namespace)
                } = {
                    enum(e, namespace)
                };'
                for e in enums
            ) }
        }};
    """

def protocol(root: ET.Element):
    if root.tag != 'protocol':
        raise Exception("root is not a protocol")

    name = root.attrib['name']

    namespace = commonPrefix([
        child.attrib['name']
        for child in root
        if child.tag == 'interface'
    ]).split('_')[0]

    if not namespace:
        print(f"Warning: protocol '{name}' has no namespace")

    try:
        cprt = next(
            child.text for child in root
            if child.tag == 'copyright' and child.text is not None
        )
    except StopIteration:
        cprt = ''
    else:
        cprt = '\n'.join(f'// {line}' for line in cprt.split('\n'))

    interfaces = [
        interface(child, namespace)
        for child in root
        if child.tag == 'interface'
    ]

    return f"""
        {cprt}

        const types = @import("types.zig");

        {'\n'.join(interfaces)}
    """, namespace

def find_protocols() -> list[Path]:
    base = Path.cwd() / 'thirdparty'
    core = [base / 'wayland.xml']
    stable = list(base.glob("**/stable/**/*.xml"))
    staging = list(base.glob("**/staging/**/*.xml"))
    unstable = list(base.glob("**/unstable/**/*.xml"))
    # filter out stable protocols
    def hasStableVersion(f: Path) -> bool:
        unneeded = lambda part: match('^(unstable)|(v[0-9]+)$', part)
        filtername = lambda name: '-'.join(part for part in name.split('-') if not unneeded(part))
        return filtername(f.stem) in (filtername(s.stem) for s in stable)
    unstable = [f for f in unstable if not hasStableVersion(f)]
    return core + stable + unstable + staging

def handler(f, n, i, t) -> str:
    name = i.removeprefix(f'{n}_') if n else i
    tp = f'{f}.{name}.{t}'
    return f'std.EnumArray({tp}, ?struct {{ context: *anyopaque, call: *const fn (*anyopaque, u32, {tp}, []const u8) void, }},),'

def main(args):
    if not len(args):
        args = find_protocols()

    destination.mkdir(parents=True, exist_ok=True)

    interfaces = []

    for file in args:
        tree = ET.parse(file)

        root = tree.getroot()
        try:
            proto, namespace = protocol(root)
        except Exception as e:
            print(f"Error: Invalid wayland file - {e}")
            continue

        output = destination / f"{root.attrib['name']}.zig"
        with open(output, 'w') as f:
            f.write(zigFormat(proto))

        interfaces += [
            (root.attrib['name'], namespace, i.attrib['name'])
            for i in root
            if i.tag == 'interface'
        ]

    fnptr = '?struct { context: *anyopaque, call: *const fn (*anyopaque, u32, enum {}, []const u8) void, },'
    types = destination / 'types.zig'
    index = destination / 'proto.zig'
    with types.open('w') as f:
        f.write(zigFormat(definitions));
    # ```    wl_display: std.EnumArray(wayland.display.event, *const fn (u32) void),```
    with index.open('w') as f:
        f.write(zigFormat(f"""
            const std = @import("std");

            { '\n'.join(
                f'const {f} = @import("{f}.zig");'
                for f in { f for f, _, _ in interfaces }
            ) }

            pub const types = @import("types.zig");

            pub const Interface = enum {{
                invalid,
                { '\n'.join(f'{i},' for _, _, i in interfaces) }
            }};

            pub const Requests = union(Interface) {{
                invalid: std.EnumArray(enum {{}}, {fnptr}),
                { '\n'.join(
                    f'{i}: {handler(f, n, i, 'request')}'
                    for f, n, i in interfaces
                ) }
            }};

            pub const Events = union(Interface) {{
                invalid: std.EnumArray(enum {{}}, {fnptr}),
                { '\n'.join(
                    f'{i}: {handler(f, n, i, 'event')}'
                    for f, n, i in interfaces
                ) }
            }};
        """))

if __name__ == "__main__":
    main(argv[1:])
