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
