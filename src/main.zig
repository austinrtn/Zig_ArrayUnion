const std = @import("std");
pub const ArrayUnion = @import("ArrayUnion.zig").ArrayUnion;

pub const Mode = enum{Single, Array, NoValue};
pub const ArrayUnionErrors = error{TypeMismatch, ExpectingNonNullValue};
pub const version = "0.1.0";

pub fn createSingle(comptime T: type, comptime size: usize, value: T) ArrayUnion(T, size){
    var instance = ArrayUnion(T, size){};
    instance.setSingleValue(value);
    return instance;
}

pub fn createArray(comptime T: type, comptime size: usize, value: [size]T) ArrayUnion(T, size){
    var instance = ArrayUnion(T, size){};
    instance.setArrayValue(value);
    return instance;
}

pub fn createArrayAndFill(comptime T: type, comptime size: usize, value: T) ArrayUnion(T, size){
    var instance = ArrayUnion(T, size){};
    instance.fillArray(value);
    return instance;
}

test "library exports" {
    const testing = std.testing;
    
    // Test that we can create types
    const IntUnion = ArrayUnion(i32, 5);
    _ = IntUnion;
    
    // Test convenience functions
    var single_union = createSingle(i32, 5, 42);
    try testing.expect(single_union.isSingle());
    
    const array_values = [_]i32{1, 2, 3, 4, 5};
    var array_union = createArray(i32, 5, array_values);
    try testing.expect(array_union.isArray());
}
