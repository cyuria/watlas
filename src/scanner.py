#!/usr/bin/env python3

""" ZigScanner
A python script to enumerate wayland protocol requests and events
"""

from pathlib import Path
from subprocess import check_output
from sys import argv
from xml.etree import ElementTree as ET

destination = Path(__file__).parent / "protocols"

substitutions = {
    "async",
    "const",
    "error",
    "export",
    "struct",
    "var",
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
pub const String = extern struct {
    ptr: [*c]const u8,
    len: u32,
};
pub const Array = extern struct {
    ptr: [*c]const u32,
    len: u32,
};
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

def method(element: ET.Element, namespace: str) -> str:
    name = rename(element.attrib['name'], namespace)
    args = [child for child in element if child.tag == 'arg']
    if not args:
        return f"{name}: void,"
    return f"""
        {name}: extern struct {{
            {'\n'.join(argument(arg) for arg in args)}
        }},
    """

def enumEntry(element: ET.Element, namespace) -> str:
    name = rename(element.attrib['name'], namespace)
    value = element.attrib['value']
    return f"{name} = {value},"

def enum(element: ET.Element, namespace: str) -> str:
    name = rename(element.attrib['name'], namespace)
    entries = [child for child in element if child.tag == 'entry']
    return f"""
        pub const {name} = enum(u32) {{
            {'\n'.join(enumEntry(e, namespace) for e in entries)}
        }};
    """

def interface(element: ET.Element, namespace: str) -> str:
    name = element.attrib['name']
    if not name.startswith(f'{namespace}_'):
        raise Exception("interface does not start with namespace")
    name = name.removeprefix(f'{namespace}_')

    requests = '\n'.join(
        method(child, namespace)
        for child in element
        if child.tag == 'request'
    )
    events = '\n'.join(
        method(child, namespace)
        for child in element
        if child.tag == 'event'
    )
    enums = '\n'.join(
        enum(child, namespace)
        for child in element
        if child.tag == 'enum'
    )
    return f"""
        pub const {name} = struct {{
            pub const request = union(enum) {{
                {requests}
            }};

            pub const event = union(enum) {{
                {events}
            }};

            {enums}
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
    """

def find_protocols() -> list[Path]:
    core = Path('/usr/share/wayland/wayland.xml')
    protocols = Path('/usr/share/wayland-protocols/')
    stable = protocols / 'stable'
    staging = protocols / 'staging'
    unstable = protocols / 'unstable'

    if not core.exists():
        raise Exception("No wayland core protocol file found, "
            "try installing libwayland")
    for dir in (protocols, stable, staging, unstable):
        if not dir.is_dir():
            raise Exception(f"No directory '{dir}' found")

    names = set()
    all = [core]

    for dir in (stable, staging, unstable):
        for protocol in dir.iterdir():
            if protocol.name in names:
                continue
            names.add(protocol.name)
            all += list(protocol.iterdir())

    return all

def main(args):
    if not len(args):
        args = find_protocols()

    destination.mkdir(parents=True, exist_ok=True)

    interfaces = []

    for file in args:
        tree = ET.parse(file)

        root = tree.getroot()
        try:
            proto = protocol(root)
        except Exception as e:
            print(f"Error: Invalid wayland file - {e}")
            continue

        output = destination / f"{root.attrib['name']}.zig"
        with open(output, 'w') as f:
            f.write(zigFormat(proto))

        interfaces += [
            i.attrib['name']
            for i in root
            if i.tag == 'interface'
        ]

    index = destination / 'types.zig'
    with index.open('w') as f:
        f.write(zigFormat(f"""
            {definitions}
            pub const Interface = enum {{
                invalid,
                { '\n'.join(f'{i}, ' for i in interfaces) }
            }};
        """))

if __name__ == "__main__":
    main(argv[1:])
