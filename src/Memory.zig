// Memory.zig

/// This is a module dedicated to calculating currently used
/// memory on a system. It works by using the /proc/meminfo file
/// and calculating total memory usage in the file.


const meminfo_path = "/proc/meminfo";

const MemErr = error {PermErr};

pub const MemDatum = struct {
    ram_free: u64 = 0,
    ram_used: u64 = 0,
    buffer: [128]u8 = undefined,

    pub fn update(self: *MemDatum) MemErr!void {
        self.ram_free = 0;
        self.ram_used = 0;
    }
};

// end Memory.zig
