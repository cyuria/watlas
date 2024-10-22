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

const types = @import("types.zig");

pub const primary_selection_device_manager_v1 = struct {
    pub const request = enum {
        create_source,
        get_device,
        destroy,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        create_source: extern struct {
            id: u32,
        },
        get_device: extern struct {
            id: u32,
            seat: u32,
        },
        destroy: void,
    };

    pub const ev = union(event) {};
};

pub const primary_selection_device_v1 = struct {
    pub const request = enum {
        set_selection,
        destroy,
    };

    pub const event = enum {
        data_offer,
        selection,
    };

    pub const rq = union(request) {
        set_selection: extern struct {
            source: u32,
            serial: u32,
        },
        destroy: void,
    };

    pub const ev = union(event) {
        data_offer: extern struct {
            offer: u32,
        },
        selection: extern struct {
            id: u32,
        },
    };
};

pub const primary_selection_offer_v1 = struct {
    pub const request = enum {
        receive,
        destroy,
    };

    pub const event = enum {
        offer,
    };

    pub const rq = union(request) {
        receive: extern struct {
            mime_type: types.String,
        },
        destroy: void,
    };

    pub const ev = union(event) {
        offer: extern struct {
            mime_type: types.String,
        },
    };
};

pub const primary_selection_source_v1 = struct {
    pub const request = enum {
        offer,
        destroy,
    };

    pub const event = enum {
        send,
        cancelled,
    };

    pub const rq = union(request) {
        offer: extern struct {
            mime_type: types.String,
        },
        destroy: void,
    };

    pub const ev = union(event) {
        send: extern struct {
            mime_type: types.String,
        },
        cancelled: void,
    };
};