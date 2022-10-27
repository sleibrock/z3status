// source

const std = @import("std");
const io = std.io;
const systime = std.time;

// local modules
const Time = @import("Time.zig");
const Load = @import("Load.zig");

// static defined vars
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

/// This is the main function to handle the status bar.
/// Utilizes and collects all information and cycles every loop
pub fn main() !void {
    var time_d: Time.TimeDatum = undefined;
    time_d.init();

    var load_d: Load.LoadDatum = undefined;
    load_d.init();

    while (true) {
        time_d.update();
        try load_d.update();
        try stdout.print(
            "Load: 1m={d}, 5m={d}, 15m={d} | ",
            .{load_d.loads[0], load_d.loads[1], load_d.loads[2]}
        );
        try stdout.print("{s}\n", .{time_d.buffer[0..time_d.chars_used]});
        systime.sleep(seconds(15));
    }
    return;
}

// end source
