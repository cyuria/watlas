#!/usr/bin/env python3

""" ZigScanner
A python script to enumerate wayland protocol requests and events
"""

from pathlib import Path
from subprocess import check_call
from sys import argv
from xml.etree import ElementTree as ET

destination = Path("protocols")

substitutions = {
    "error",
    "export",
    "struct",
    "const",
    "var",
}

def commonPrefix(strs: list[str]):
    if not strs:
        return ""

    for i, letters in enumerate(zip(*strs)):
        if len(set(letters)) > 1:
            return strs[0][:i]
    return min(strs, key=len)

class Interface:
    def __init__(self, namespace: str = ''):
        self.namespace = namespace
        self.name = ''
        self.requests = []
        self.events = []

    def parse(self, element: ET.Element):
        self.name = element.attrib.get('name')
        if self.name is None:
            raise Exception("interface has no name")
        if not self.name.startswith(self.namespace):
            raise Exception("interface does not start with namespace")
        self.name = self.name.removeprefix(self.namespace)

        def rename(name: str | None) -> str:
            if name is None:
                raise Exception("event or request has no name")
            prefix = '' if name not in substitutions else self.namespace
            return prefix + name

        self.requests = [
            rename(child.attrib.get('name'))
            for child in element
            if child.tag == 'request'
        ]
        self.events = [
            rename(child.attrib.get('name'))
            for child in element
            if child.tag == 'event'
        ]

    def generate(self) -> str:
        requests = ''.join(f"{op}, " for op in self.requests)
        events = ''.join(f"{ev}, " for ev in self.events)
        return f"""
                pub const {self.name} = struct {{
                    pub const op = enum(u16) {{{requests}}};
                    pub const ev = enum(u16) {{{events}}};
                }};
        """

class Protocol:
    def __init__(self):
        self.name = ''
        self.interfaces: list[Interface] = []

    def parse(self, root: ET.Element):
        if root.tag != 'protocol':
            raise Exception("root is not a protocol")

        self.name = root.attrib.get('name', '')

        if not self.name:
            raise Exception("protocol has no name")

        self.namespace = commonPrefix([
            child.attrib.get('name', '')
            for child in root
            if child.tag == 'interface'
        ])

        if self.namespace and self.namespace[-1] != '_':
            self.namespace = '_'.join(self.namespace.split('_')[:-1])

        if not self.namespace:
            print(f"Warning: protocol '{self.name}' has no namespace")
        
        for child in root:
            if child.tag == 'copyright':
                print("==== COPYRIGHT NOTICE ====")
                print(child.text)
                continue
            if child.tag == 'interface':
                self.interfaces.append(Interface(self.namespace))
                self.interfaces[-1].parse(child)
                continue
            print(f"Unknown tag '{child.tag}', skipping...")

    def generate(self) -> str:
        return '\n'.join(i.generate() for i in self.interfaces)

def parse_file(input: Path, output: Path):
    tree = ET.parse(input)
    proto = Protocol()

    try:
        proto.parse(tree.getroot())
    except Exception as e:
        print(f"Error: Invalid wayland file - {e}")
        return

    with open(output, 'w') as f:
        f.write(proto.generate())
    check_call(['zig', 'fmt', output])

def find_protocols() -> list[Path]:
    core = Path('/usr/share/wayland/wayland.xml')
    protocols = Path('/usr/share/wayland-protocols/')

    if not core.exists():
        raise Exception("No wayland core protocol file found, try installing "
            "libwayland")
    if not protocols.is_dir():
        raise Exception("No directory '/usr/share/wayland-protocols' found")

    return [core, *protocols.rglob("*.xml")]

def main(args):
    if not len(args):
        args = find_protocols()

    destination.mkdir(parents=True, exist_ok=True)
    files = []

    for file in args:
        tree = ET.parse(file)
        proto = Protocol()

        try:
            proto.parse(tree.getroot())
        except Exception as e:
            print(f"Error: Invalid wayland file - {e}")

        output = destination / f"{proto.name}.zig"
        with open(output, 'w') as f:
            f.write(proto.generate())
        check_call(['zig', 'fmt', output])
        files.append(output)

if __name__ == "__main__":
    main(argv[1:])
