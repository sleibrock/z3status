// Memory.zig

/// This is a module dedicated to calculating currently used
/// memory on a system. It works by using the /proc/meminfo file
/// and calculating total memory usage in the file.

const std = @import("std");
const fs = std.fs;

const meminfo_path = "/proc/meminfo";

const MemErr = error {
    NoMeminfo,    // you don't have a Linux system
    PermDenied,   // program can't read due to permissions
    LockErr,      // another program has a lock on the file
    OtherErr,     // something else I can't think of
};

pub const MemDatum = struct {
    ram_free: u64 = 0,
    ram_used: u64 = 0,
    buffer: [128]u8 = undefined,

    /// Update the memory tracker by parsing through
    /// the /proc/meminfo file
    pub fn update(self: *MemDatum) MemErr!void {
        self.ram_free = 0;
        self.ram_used = 0;
    }
};

// end Memory.zig
