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
const std = @import("std");
const fs = std.fs;
const cTime = @cImport(@cInclude("time.h"));
const S = @import("Settings.zig");
const Utils = @import("utils.zig");

pub fn update(start: u8, end: u8, buf: *[128]u8, s: S.AppSettings) Utils.UtilErr!u8 {
    _ = s;
    var time_raw: cTime.time_t = undefined;
    var time_info: cTime.struct_tm = undefined;
    var output: [20]u8 = undefined;
    _ = cTime.time(&time_raw); // returns void
    time_info = cTime.localtime(&time_raw).*;

    // this function returns the number of characters actually used
    const c_used = cTime.strftime(&output, 20, "%Y-%m-%d %H:%M:%S", &time_info);
    if (c_used == 0) {
        return 1;
    }

    // copy the values from local output to main buffer
    var c_index: usize = c_used;
    var end_index: usize = end;
    while ((c_index > 0) and (end_index > start)) {
        c_index -= 1;
        buf[end_index] = output[c_index];
        end_index -= 1;
    }

    return 0;
}

// end Time.zig
