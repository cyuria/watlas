//
//     Copyright © 2018 NXP
//     Copyright © 2019 Status Research & Development GmbH.
//     Copyright © 2021 Xaver Hugl
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

const device_v1 = struct {
    const create_lease_request: u16 = 0;
    const release: u16 = 1;
    const drm_fd: u16 = 0;
    const connector: u16 = 1;
    const done: u16 = 2;
    const released: u16 = 3;
};

const connector_v1 = struct {
    const destroy: u16 = 0;
    const name: u16 = 0;
    const description: u16 = 1;
    const connector_id: u16 = 2;
    const done: u16 = 3;
    const withdrawn: u16 = 4;
};

const request_v1 = struct {
    const request_connector: u16 = 0;
    const submit: u16 = 1;
};

const v1 = struct {
    const destroy: u16 = 0;
    const lease_fd: u16 = 0;
    const finished: u16 = 1;
};
