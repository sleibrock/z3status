// source

const std = @import("std");
const io = std.io;
const time = std.time;

const cTime = @cImport(@cInclude("time.h"));

const stdout = io.getStdOut().writer();

/// Convert an integer into nanoseconds
/// Has a check to prevent a possible u64 overflow
/// so it caps out at 60 seconds sleep time
fn seconds(n: u64) u64 {
    var x: u64 = switch (n) {
        0...60 => n,
        else => 60,
    };
    return x * 1000000000;
}

pub fn main() !void {
    var time_raw: cTime.time_t = undefined;
    var time_info: cTime.struct_tm = undefined;
    var buf: [80]u8 = undefined;

    _ = cTime.time(&time_raw);
    time_info = cTime.localtime(&time_raw).*;
    while (true) {
        _ = cTime.strftime(&buf, 80, "%x - %I:%M%p", &time_info);
        try stdout.print("{s}\n", .{buf});
        time.sleep(seconds(15));
    }
    return;
}

// end source
