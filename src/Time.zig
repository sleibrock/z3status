// Time.zig - a wrapper for libc/time.h

/// Time.zig is a module for encapsulating datetime logic.
/// This module depends on libc/time.h and as such
/// is contained in it's own basic struct called TimeDatum.
/// TimeDatum is initialized undefined at the start, then
/// uses the libc/time.h library to seek values from the
/// local system and adjust the current time and other
/// information like tzinfo. Each time a cycle is completed,
/// it should be manually updated using .update().
///
/// In short,
/// * initialize using var t: Time.TimeDatum = undefined;
/// * update using TimeDatum.update()

const cTime = @cImport(@cInclude("time.h"));

pub const TimeDatum = struct {
    time_raw: cTime.time_t = undefined,
    time_info: cTime.struct_tm = undefined,
    chars_used: u64 = undefined,
    buffer: [80]u8 = undefined,

    pub fn init(self: *TimeDatum) void {
        _ = cTime.time(&self.time_raw);
        self.time_info = cTime.localtime(&self.time_raw).*;
    }

    pub fn update(self: *TimeDatum) void {
        self.chars_used = cTime.strftime(
            &self.buffer, 80, "%x - %I:%M%p", &self.time_info
        );
    }
};



// end Time.zig
