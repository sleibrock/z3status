const std = @import("std");
const fs = std.fs;

pub const UtilErr = error{
    ReadUntilError,
};

/// Convert an integer into nanoseconds
/// Has a check to prevent a possible u64 overflow
/// so it caps out at 60 seconds sleep time
pub fn seconds(n: u64) u64 {
    var x: u64 = switch (n) {
        0...60 => n,
        else => 60,
    };
    return x * 1000000000;
}

/// Read a File until we reach a given target character. Provides
/// ability to read a file until a target (like newline) is hit.
pub fn readUntil(f: *fs.File, tgt: u8, buf: [*]u8, bufmax: u64) UtilErr!u64 {
    var total_chars: u64 = 0;
    var index: u64 = 0;
    var result: u64 = 0;

    while (index < bufmax) : (index += 1) {
        // awful? or genius?
        result = f.read(buf[index..(index + 1)]) catch |err| {
            switch (err) {
                else => {
                    return UtilErr.ReadUntilError;
                },
            }
        };
        total_chars += result;
        if (buf[index] == tgt) {
            return total_chars;
        }
    }
    return total_chars;
}

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
pub fn toBase10(buf: [*]const u8, start_index: u64, buflen: u64) u64 {
    if (buflen == 0 or start_index > buflen) {
        return 0;
    }
    var index: u64 = buflen - 1;
    var result: u64 = 0;
    var current_multiplier: u64 = 1;
    var was_added: u1 = 0;
    var to_use: u64 = 0;

    while (index >= start_index) {
        was_added = 0;
        to_use = 0;
        switch (buf[index]) {
            '0' => {
                to_use = 0;
                was_added = 1;
            },
            '1' => {
                to_use = 1;
                was_added = 1;
            },
            '2' => {
                to_use = 2;
                was_added = 1;
            },
            '3' => {
                to_use = 3;
                was_added = 1;
            },
            '4' => {
                to_use = 4;
                was_added = 1;
            },
            '5' => {
                to_use = 5;
                was_added = 1;
            },
            '6' => {
                to_use = 6;
                was_added = 1;
            },
            '7' => {
                to_use = 7;
                was_added = 1;
            },
            '8' => {
                to_use = 8;
                was_added = 1;
            },
            '9' => {
                to_use = 9;
                was_added = 1;
            },
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

// Human-readable byte conversion stuff here
pub const ByteSizes = [_]u8{ ' ', 'K', 'M', 'G', 'T', 'P' };

/// Get the human-readable symbol
pub fn getSymbol(index: u8) u8 {
    return switch (index) {
        0...5 => ByteSizes[index],
        else => 0,
    };
}

/// Convert a length of bytes into a human readable format.
/// The output value has to be trimmed/rounded afterwards
/// due to floating-point precisions.
pub fn humanReadableBytes(in_bytes: u64, divisor: u64, counter: *u8) f64 {
    var bytes: f64 = 0.0;
    var div: f64 = 1.0;
    bytes = @intToFloat(f64, in_bytes);
    div = @intToFloat(f64, divisor);
    counter.* = 0;
    while ((bytes >= div) and (counter.* < 6)) {
        bytes /= div;
        counter.* += 1;
    }
    return bytes;
}

// Testing section

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
    const num100 = [_]u8{ '1', '0', '0' };
    try std.testing.expect(100 == toBase10(&num100, 0, 3));
}

test "Converting \"9876543210\" to u64" {
    const num = [_]u8{ '9', '8', '7', '6', '5', '4', '3', '2', '1', '0' };
    try std.testing.expect(9876543210 == toBase10(&num, 0, 10));
}

test "Converting a messy mixed string to u64" {
    const num = [_]u8{ '1', '0', '0', ' ', 'k', 'B' };
    try std.testing.expect(100 == toBase10(&num, 0, 6));
}

test "Converting a test sample from /proc/meminfo" {
    const num = "MemTotal:       16347412 kB";
    try std.testing.expect(16347412 == toBase10(num, 9, 25));
}

// end utils.zig
