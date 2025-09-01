const std = @import("std");
pub const ArrayUnion = @import("ArrayUnion.zig").ArrayUnion;

pub const Mode = enum{Single, Array, NoValue};
pub const ArrayUnionErrors = error{TypeMismatch, ExpectingNonNullValue, IndexOutOfBounds};
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


const testing = std.testing;

test "test_single" { 
    var au = ArrayUnion(i32, 5){};
    const foo: i32 = 5;
    au.setSingleValue(foo);
    
    const result1 = au.getSingleValue();
    if(result1) |val| {
        try testing.expect(val == 5);
    }
    else {
        try testing.expect(result1 == null);
    }

    const result2 = try au.expectSingle();
    try testing.expect(result2 == 5);

    try testing.expect(au.isSingle() == true);
}

test "test_array" {
    var au = ArrayUnion(i32, 5){};    
    const foo: [5]i32 = .{0,1,2,3,4};
    au.setArrayValue(foo);

    const result1 = au.getArrayValue();
    if(result1) |val| {
        try testing.expect(std.mem.eql(i32, &val, &foo));
    } else {
        try testing.expect(result1 == null);
    }

    const result2 = try au.expectArray();
    try testing.expect(std.mem.eql(i32, &foo, &result2));

    try testing.expect(au.isArray() == true);

    au.fillArray(69);
    const result3 = try  au.expectArray();
    try testing.expect(result3[0] == 69); 
}

test "other" {
    var au = ArrayUnion(i32, 5){};
    try au.setValue(69);
    try testing.expect(try au.expectSingle() == 69);

    const ar: [5]i32 = .{1,2,3,4,5};
    try au.setValue(ar);
    const result = try au.expectArray();
    try testing.expect(std.mem.eql(i32, &result, &ar));
}
