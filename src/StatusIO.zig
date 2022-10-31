// Printer.zig

const std = @import("std");
const io = std.io;

const stdout = io.getStdOut().writer();

const LoadGauge = enum {
    Low, Medium, High,

    pub fn how_high(x: f64) LoadGauge {
        if (x > 4.0) {
            return LoadGauge.High;
        }
        if (x > 2.0) {
            return LoadGauge.Medium;
        }
        return LoadGauge.Low;
    }
};

pub const StatusIO = struct {
    flags: u8,
    separator: u8,

    /// Take in a slice to an array containing Time info
    pub fn time(self: *StatusIO, buf: []u8, len: u64) !void {
        self.flags = 0;

        try stdout.print("{s} ", .{buf[0..len]});
    }

    pub fn load(self: *StatusIO, buf: [3]f64) !void {
        // round to two digits
        var load1m = buf[0] * 100.0;
        load1m = @round(load1m);
        load1m = load1m * 0.01;
        try stdout.print("{d} {c} ", .{load1m, self.separator});
    }

    /// Print out a newline and kill a sequence
    pub fn newline(self: *StatusIO) !void {
        self.flags = 1;
        try stdout.print("\n", .{});
    }
};


// end StatusIO.zig
