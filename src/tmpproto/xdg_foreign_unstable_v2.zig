//
//     Copyright © 2015-2016 Red Hat Inc.
//
//     Permission is hereby granted, free of charge, to any person obtaining a
//     copy of this software and associated documentation files (the "Software"),
//     to deal in the Software without restriction, including without limitation
//     the rights to use, copy, modify, merge, publish, distribute, sublicense,
//     and/or sell copies of the Software, and to permit persons to whom the
//     Software is furnished to do so, subject to the following conditions:
//
//     The above copyright notice and this permission notice (including the next
//     paragraph) shall be included in all copies or substantial portions of the
//     Software.
//
//     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//     IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
//     THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//     FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//     DEALINGS IN THE SOFTWARE.
//

const exporter_v2 = struct {
    const destroy: u16 = 0;
    const export_toplevel: u16 = 1;
};

const importer_v2 = struct {
    const destroy: u16 = 0;
    const import_toplevel: u16 = 1;
};

const exported_v2 = struct {
    const destroy: u16 = 0;
    const handle: u16 = 0;
};

const imported_v2 = struct {
    const destroy: u16 = 0;
    const set_parent_of: u16 = 1;
    const destroyed: u16 = 0;
};
