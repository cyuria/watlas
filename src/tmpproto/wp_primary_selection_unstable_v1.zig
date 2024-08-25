//
//     Copyright © 2015, 2016 Red Hat
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

const device_manager_v1 = struct {
    const create_source: u16 = 0;
    const get_device: u16 = 1;
    const destroy: u16 = 2;
};

const device_v1 = struct {
    const set_selection: u16 = 0;
    const destroy: u16 = 1;
    const data_offer: u16 = 0;
    const selection: u16 = 1;
};

const offer_v1 = struct {
    const receive: u16 = 0;
    const destroy: u16 = 1;
    const offer: u16 = 0;
};

const source_v1 = struct {
    const offer: u16 = 0;
    const destroy: u16 = 1;
    const send: u16 = 0;
    const cancelled: u16 = 1;
};
