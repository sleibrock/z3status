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

// debug, strip later
const io = std.io;
const stdout = io.getStdOut().writer();

const MemBufSize:u64 = 128;

// support up to exabytes
const ByteSizes = [_]u8{' ', 'K', 'M', 'G', 'T', 'P'};

const meminfo_path = "/proc/meminfo";

const MemErr = error {
    NoMeminfo,    // you don't have a Linux system
    PermDenied,   // program can't read due to permissions
    LockErr,      // another program has a lock on the file
    OtherErr,     // something else I can't think of
};


/// Base-10 conversion string method. Since Zig doesn't have a
/// great way of doing this for me, I am writing my own.
/// The /proc/meminfo file contains dirty data of memory mappings
/// in the system, and it proves difficult to read/search properly
/// and convert numerical strings to u64. This function aims to
/// read a line of text and convert the string to a number starting
/// from the back and increasing the base-10 multiplier each time
/// a valid numerical character is encountered. It's easier
/// to start from the back and go to the left, because we don't have
/// a basis to judge how large the first digit actually is until we
/// reach the end of string.
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
        if (index == start_index) {
            return result;
        } else {
            index -= 1;
        }
    }
    return 0;
}

/// Read a File until we reach a given target character. Provides
/// ability to read a file until a target (like newline) is hit.
fn readUntil(f: *fs.File, target: u8, buf: [*]u8, bufmax: u64) !u64 {

    var total_chars: u64 = 0;
    var index: u64 = 0;
    var result: u64 = 0;

    while (index < bufmax) : (index += 1) {
        // awful? or genius?
        result = f.read(buf[index..(index+1)]) catch |err| {
            switch (err) {
                else => { return MemErr.OtherErr; },
            }
        };
        total_chars += result;
        if (buf[index] == target) {
            return total_chars;
        }
    }
    return total_chars;
}


pub const MemDatum = struct {
    ram_free: u64 = 0,
    ram_used: u64 = 0,
    ram_total: u64 = 0,
    metric: u8 = 0,
    buffer: [128]u8 = undefined,

    pub fn metric(self: *MemDatum) u8 {
        return ByteSizes[self.metric];
    }

    pub fn calc_metric(self: *MemDatum) void {
        _ = self;

    }

    /// Update the memory tracker by parsing through
    /// the /proc/meminfo file
    pub fn update(self: *MemDatum) !void {
        self.ram_free = 0;
        self.ram_used = 0;
        self.ram_total = 0;

        var flock = fs.cwd().openFileZ(meminfo_path, .{ .mode = .read_only }) catch |err| {
            // handle error better maybe?
            switch (err) {
                else => { return MemErr.OtherErr; },
            }
        };
        defer flock.close();

        var bytes_read : u64 = 0;
        var index: u64 = 0;
        _ = index;
        var running: u1 = 1;

        while (running > 0) {
            self.buffer = undefined; // reset
            bytes_read = try readUntil(&flock, '\n', &self.buffer, 128);

            // if no bytes read, either error, or EOF
            if (bytes_read == 0) {
                running = 0;
            }

            // begin checking the buffer and count bytes
            // convert the number to bytes by mult'ing by 1024
            if (memlib.startsWith(u8, &self.buffer, "MemTotal:")) {
                self.ram_total = toBase10(&self.buffer, 10, bytes_read);
                self.ram_total *= 1024;
            }
            if (memlib.startsWith(u8, &self.buffer, "MemAvailable:")) {
                self.ram_free = toBase10(&self.buffer, 13, bytes_read);
                self.ram_free *= 1024;
            }

            // compute how much is used in total
            if (self.ram_total > 0 and self.ram_free > 0) {
                self.ram_used = self.ram_total - self.ram_free;

                // calculate the suffix used (kb, mb, etc)
                // one time call that should not be required after initial call
                if (self.metric == 0) {
                    self.calc_metric();
                }
            }
        }

        return; // end
    }
};


// Do number conversion testing here, since it's dirty
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

test "Converting a messy mixed string to u64" {
    const num = [_]u8{'1', '0', '0', ' ', 'k', 'B'};
    try std.testing.expect(100 == toBase10(&num, 0, 6));
}

test "Converting a test sample from /proc/meminfo" {
    const num = "MemTotal:       16347412 kB";
    try std.testing.expect(16347412 == toBase10(num, 9, 25));
}

// end Memory.zig
