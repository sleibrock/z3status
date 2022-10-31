// main.zig - assemble all the things here

const std = @import("std");
const io = std.io;
const systime = std.time;

// local modules
const Time = @import("Time.zig");
const Load = @import("Load.zig");
const Memory = @import("Memory.zig");
const StatusIO = @import("StatusIO.zig");

// static defined vars
//const stdout = io.getStdOut().writer();

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
    var load_d: Load.LoadDatum = undefined;
    var status_io: StatusIO.StatusIO = undefined;
    status_io.separator = '|';

    while (true) {
        try time_d.update();
        try load_d.update();

        try status_io.load(load_d.loads);
        
        try status_io.time(&time_d.buffer, time_d.chars_used);
        try status_io.newline();
        
        systime.sleep(seconds(15));
    }
    return;
}

// end source
