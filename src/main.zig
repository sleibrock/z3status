// main.zig - assemble all the things here

const std = @import("std");
const io = std.io;
const systime = std.time;

// local modules
const Utils = @import("utils.zig");
const S = @import("Settings.zig");
const Time = @import("Time.zig");
const Load = @import("Load.zig");
const Memory = @import("Memory.zig");
//const StatusIO = @import("StatusIO.zig");

// static defined vars
const stdout = io.getStdOut().writer();

const BufSize: u8 = 128;

const MyErr = error{};

var chars: [BufSize]u8 = undefined;
const updateT = fn (u8, u8, *[BufSize]u8, S.AppSettings) Utils.UtilErr!u8;

// Create a "widget" that stores information about buffer dimensions
// and the function used to set information into the output buffer
const Widget = struct {
    start: u8,
    end: u8,
    updater: *const updateT,
};

const widgets = [_]Widget{
    Widget{ .start = 91, .end = 101, .updater = &Memory.update },
    Widget{ .start = 101, .end = 107, .updater = &Load.update },
    Widget{ .start = 107, .end = 127, .updater = &Time.update },
};

/// This is the main function to handle the status bar.
/// Utilizes and collects all information and cycles every loop
pub fn main() !void {
    var index: usize = 0;
    while (index < 128) : (index += 1) {
        chars[index] = ' ';
    }
    while (true) {
        for (widgets) |widget| {
            _ = try widget.updater(widget.start, widget.end, &chars, .None);
        }

        try stdout.print("{s}\n", .{chars});
        systime.sleep(Utils.seconds(15));
    }
    return;
}

// end main.zig
