// Memory.zig

/// This is a module dedicated to calculating currently used
/// memory on a system. It works by using the /proc/meminfo file
/// and calculating total memory usage in the file.
///
/// Notes: is it better to keep a file lock open the
/// entire span of the program?
/// Scenario 1: keep a lock open per instance of a Memory
/// info module, and that lifespan is kept until program end.
/// Is it best practice to store a file lock indefinitely?
///
/// Scenario 2: open a new file lock each time the program
/// is updated, which could have delays due to kernel request
/// and/or syscall timing. This sounds better in practice
/// and much safer.

const std = @import("std");
const fs = std.fs;
const memlib = std.mem;

const MemBufSize:u64 = 128;

const meminfo_path = "/proc/meminfo";

const MemErr = error {
    NoMeminfo,    // you don't have a Linux system
    PermDenied,   // program can't read due to permissions
    LockErr,      // another program has a lock on the file
    OtherErr,     // something else I can't think of
};


fn toBase10(buf: [*]const u8, start_index: u64, buflen: u64) u64 {
    if (buflen == 0 or start_index > buflen) {
        return 0;
    }
    var index : u64 = buflen - 1;
    var result : u64 = 0;
    var current_multiplier: u64 = 1;
    var was_added : u1 = 0;
    var to_use : u64 = 0;

    while (index >= start_index) {
        was_added = 0;
        to_use = 0;
        switch (buf[index]) {
            '0' => { to_use = 0; was_added = 1; },
            '1' => { to_use = 1; was_added = 1; }, 
            '2' => { to_use = 2; was_added = 1; },
            '3' => { to_use = 3; was_added = 1; },
            '4' => { to_use = 4; was_added = 1; },
            '5' => { to_use = 5; was_added = 1; },
            '6' => { to_use = 6; was_added = 1; },
            '7' => { to_use = 7; was_added = 1; },
            '8' => { to_use = 8; was_added = 1; },
            '9' => { to_use = 9; was_added = 1; },
            else => {},
        }
        if (was_added > 0) {
            result += to_use * current_multiplier;
            current_multiplier *= 10;
        }
        if (index == 0) {
            return result;
        } else {
            index -= 1;
        }
    }
    return 0;
}

pub const MemDatum = struct {
    ram_free: u64 = 0,
    ram_used: u64 = 0,
    ram_total: u64 = 0,
    buffer: [128]u8 = undefined,

    /// Update the memory tracker by parsing through
    /// the /proc/meminfo file
    pub fn update(self: *MemDatum) MemErr!void {
        self.ram_free = 0;
        self.ram_used = 0;
        self.ram_total = 0;

        var flock = fs.cwd().openFileZ(meminfo_path, .{ . read = true}) catch |err| {
            // handle error better maybe?
            switch (err) {
                else => { return MemErr.OtherErr; },
            }
        };
        defer flock.close();

        var bytes_read : u64 = 0;
        var index: u64 = 0;
        _ = index;

        bytes_read = flock.read(self.buffer) catch |err| {
            switch (err) {
                else => { return MemErr.OtherErr; },
            }
        };

        if (memlib.startsWith(u8, self.buffer, "MemTotal:")) {

        }
    }
};


test "Converting an empty array to zero" {
    // test if we can actually convert base10 strings to numerals properly
    const zero = [_]u8{};
    try std.testing.expect(0 == toBase10(&zero, 0, 0));
}

test "Converting a string of 1 to value 1" {
    const num1 = [_]u8{'1'};
    try std.testing.expect(1 == toBase10(&num1, 0, 1));
}

test "Converting a string of 100 to value 100" {
    const num100 = [_]u8{'1', '0', '0'};
    try std.testing.expect(100 == toBase10(&num100, 0, 3));
}

test "Converting \"9876543210\" to u64" {
    const num = [_]u8{'9', '8', '7', '6', '5', '4', '3', '2', '1', '0'};
    try std.testing.expect(9876543210 == toBase10(&num, 0, 10));
}

// end Memory.zig
