// Memory.zig

//                                                                              3.2 GB | 59.4 GB |      0.33 |  2023-01-10 00:50:01

// This is a module dedicated to calculating currently used
// memory on a system. It works by using the /proc/meminfo file
// and calculating total memory usage in the file.

const std = @import("std");
const fs = std.fs;
const fmt = std.fmt;
const memlib = std.mem;

const S = @import("Settings.zig");
const Utils = @import("utils.zig");

// can break on windows builds (because... there's no /proc/meminfo)
const meminfo_path = "/proc/meminfo";

/// Update the memory tracker by parsing through the memory file
pub fn update(start: u8, end: u8, buf: *[128]u8, s: S.AppSettings) Utils.UtilErr!u8 {
    _ = s;
    var ram_free: u64 = 0;
    var ram_used: u64 = 0;
    var ram_total: u64 = 0;
    var metric: u8 = 0;
    _ = metric;
    var mbuffer: [128]u8 = undefined; // reading buffer

    var flock = fs.cwd().openFileZ(meminfo_path, .{ .mode = .read_only }) catch |err| {
        // handle error better maybe?
        switch (err) {
            else => {
                return 10;
            },
        }
    };
    defer flock.close();

    var bytes_read: u64 = 0;
    var index: u64 = 0;
    _ = index;
    var running: u1 = 1;

    while (running > 0) {
        mbuffer = undefined; // reset
        bytes_read = try Utils.readUntil(&flock, '\n', &mbuffer, 128);

        // if no bytes read, either error, or EOF
        if (bytes_read == 0) {
            running = 0;
        }

        // begin checking the buffer and count bytes
        // convert the number to bytes by mult'ing by 1024
        if (memlib.startsWith(u8, &mbuffer, "MemTotal:")) {
            ram_total = Utils.toBase10(&mbuffer, 10, bytes_read);
            ram_total *= 1024;
        }
        if (memlib.startsWith(u8, &mbuffer, "MemAvailable:")) {
            ram_free = Utils.toBase10(&mbuffer, 13, bytes_read);
            ram_free *= 1024;
        }

        // compute how much is used in total
        if (ram_total > 0 and ram_free > 0) {
            ram_used = ram_total - ram_free;
        }
    }

    // format an output
    var sym1: u8 = 0;
    var sym2: u8 = 0;
    var used = Utils.humanReadableBytes(ram_used, 1024, &sym1);
    var free = Utils.humanReadableBytes(ram_free, 1024, &sym2);
    _ = fmt.bufPrint(
        buf[start..end],
        "{d:.1} {c}B | {d:.1} {c}B | ",
        .{ used, Utils.getSymbol(sym1), free, Utils.getSymbol(sym2) },
    ) catch |err| {
        switch (err) {
            else => {
                return 50;
            },
        }
    };

    return 0; // end
}

// end Memory.zig

