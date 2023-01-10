// Load.zig - a module for fetching system load

/// System load is an important tool used to gauge
/// how well a system is performing in every day operations.
/// System load is usually determined by using getloadavg(3),
/// and can return an error code -1 on fail. Thus this must
/// be wrapped up in Zig in some meaningful capacity.
const std = @import("std");
const fmt = std.fmt;
const Utils = @import("utils.zig");
const cStdlib = @cImport(@cInclude("stdlib.h"));

const S = @import("Settings.zig");

pub fn update(start: u8, end: u8, buf: *[128]u8, s: S.AppSettings) Utils.UtilErr!u8 {
    _ = s;
    var loads: [3]f64 = undefined;

    var err_code = cStdlib.getloadavg(&loads, 3);
    if (err_code < 0) {
        return 2;
    }

    // format the output to the buffer
    _ = fmt.bufPrint(buf[start..end], " {d:.2} |", .{loads[0]}) catch |err| {
        switch (err) {
            else => {
                return 3;
            },
        }
    };
    return 0;
}

// end Load.zig
