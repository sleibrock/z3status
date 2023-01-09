// main.zig - assemble all the things here

const std = @import("std");
const io = std.io;
const systime = std.time;

// local modules
const Utils = @import("utils.zig");
const Settings = @import("Settings.zig");
const Time = @import("Time.zig");
//const Load = @import("Load.zig");
//const Memory = @import("Memory.zig");
//const StatusIO = @import("StatusIO.zig");

// static defined vars
const stdout = io.getStdOut().writer();

var chars: [128]u8 = undefined;

/// This is the main function to handle the status bar.
/// Utilizes and collects all information and cycles every loop
pub fn main() !void {
    var index: usize = 0;
    while (index < 128) : (index += 1) {
        chars[index] = ' ';
    }
    while (true) {
        // print all the output with the statusIO module
        try Time.update(107, 127, &chars);

        try stdout.print("{s}\n", .{chars});
        systime.sleep(Utils.seconds(15));
    }
    return;
}

// end main.zig
