//
//     Copyright © 2018 Ilia Bozhinov
//     Copyright © 2020 Isaac Freund
//     Copyright © 2022 wb9688
//     Copyright © 2023 i509VCB
//
//     Permission to use, copy, modify, distribute, and sell this
//     software and its documentation for any purpose is hereby granted
//     without fee, provided that the above copyright notice appear in
//     all copies and that both that copyright notice and this permission
//     notice appear in supporting documentation, and that the name of
//     the copyright holders not be used in advertising or publicity
//     pertaining to distribution of the software without specific,
//     written prior permission.  The copyright holders make no
//     representations about the suitability of this software for any
//     purpose.  It is provided "as is" without express or implied
//     warranty.
//
//     THE COPYRIGHT HOLDERS DISCLAIM ALL WARRANTIES WITH REGARD TO THIS
//     SOFTWARE, INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
//     FITNESS, IN NO EVENT SHALL THE COPYRIGHT HOLDERS BE LIABLE FOR ANY
//     SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
//     WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN
//     AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,
//     ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF
//     THIS SOFTWARE.
//

const types = @import("types.zig");

pub const foreign_toplevel_list_v1 = struct {
    pub const request = union(enum) {
        stop: void,
        destroy: void,
    };

    pub const event = union(enum) {
        toplevel: extern struct {
            toplevel: u32,
        },

        finished: void,
    };
};

pub const foreign_toplevel_handle_v1 = struct {
    pub const request = union(enum) {
        destroy: void,
    };

    pub const event = union(enum) {
        closed: void,
        done: void,

        title: extern struct {
            title: types.String,
        },

        app_id: extern struct {
            app_id: types.String,
        },

        identifier: extern struct {
            identifier: types.String,
        },
    };
};
