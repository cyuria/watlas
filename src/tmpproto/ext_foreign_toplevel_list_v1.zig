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

const list_v1 = struct {
    const stop: u16 = 0;
    const destroy: u16 = 1;
    const toplevel: u16 = 0;
    const finished: u16 = 1;
};

const handle_v1 = struct {
    const destroy: u16 = 0;
    const closed: u16 = 0;
    const done: u16 = 1;
    const title: u16 = 2;
    const app_id: u16 = 3;
    const identifier: u16 = 4;
};
