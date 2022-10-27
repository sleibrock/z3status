// Load.zig - a module for fetching system load

/// System load is an important tool used to gauge
/// how well a system is performing in every day operations.
/// System load is usually determined by using getloadavg(3),
/// and can return an error code -1 on fail. Thus this must
/// be wrapped up in Zig in some meaningful capacity.

const cStdlib = @cImport(@cInclude("stdlib.h"));

const LoadErr = error { GeneralFail };


pub const LoadDatum = struct {
    loads: [3]f64 = undefined,

    /// Set some default values as a backup in case some failure occurs
    pub fn init(self: *LoadDatum) void {
        self.loads[0] = 0.0;
        self.loads[1] = 0.0;
        self.loads[2] = 0.0;
    }

    pub fn update(self: *LoadDatum) LoadErr!void {
        var err_code = cStdlib.getloadavg(&self.loads, 3);
        switch (err_code) {
            -1 => return LoadErr.GeneralFail,
            else => {},
        }
        return;
    }
};

// end Load.zig
