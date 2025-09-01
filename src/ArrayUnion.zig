/// ArrayUnion<T, N> stores either a single value of type T or an array of N values of type T.
/// 
/// Common use cases:
/// - Configuration that can be uniform or per-item
/// - Graphics properties that apply globally or per-element  
/// - Any scenario where you need "one value for all" vs "individual values"

const Mode = @import("main.zig").Mode;
const ArrayUnionErrors = @import("main.zig").ArrayUnionErrors;

const std = @import("std"); pub fn ArrayUnion(comptime T: type, comptime ARRAY_SIZE: usize)type {
    return struct {
        const Self = @This();
        pub const array_size = ARRAY_SIZE; 
        
        singleValue: ?T = null,
        arrayValue: ?[ARRAY_SIZE]T = null,
        mode: Mode = .NoValue,
             
        /// Sets the value, automatically detecting whether it's a single value or array.
        /// Accepts either T (single value) or [ARRAY_SIZE]T (array).
        /// Returns TypeMismatch error if value is neither type.
        /// Setting one type clears the other.
        
        pub fn setValue(self: *Self, value: anytype) !void {
            const valueType = @TypeOf(value);
            const valueTypeInfo = @typeInfo(valueType);

            if(T == valueType){ self.setSingleValue(value);}
            else if (valueTypeInfo == .array and valueTypeInfo.array.child == T and valueTypeInfo.array.len == ARRAY_SIZE){ self.setArrayValue(value); } 
            else {
                std.debug.print("Invalid datatype for setValue of ArrayUnion!");
                return ArrayUnionErrors.TypeMismatch;
            }
        }
        

        ///Setter functions that specifically set either the single or array value and will not return Error.
        pub fn setSingleValue(self: *Self, value: T) void {
            self.mode = Mode.Single;
            self.singleValue = value;
            self.arrayValue = null;
        }

        pub fn setArrayValue(self: *Self, value: [ARRAY_SIZE]T) void {
            self.mode = Mode.Array;
            self.arrayValue = value;
            self.singleValue = null;
        }

        ///Set ArrayUnion to array and fill array will parameter value
        pub fn fillArray(self: *Self, value:T) void {
            const valAr = [_]T{value} ** ARRAY_SIZE;
            self.setArrayValue(valAr);
        }

        ///Getter functions that return the optional values.
        pub fn getSingleValue(self: *const Self) ?T {
            return self.singleValue;
        }

        pub fn getArrayValue(self: *const Self) ?[ARRAY_SIZE]T {
            return self.arrayValue;
        }


        ///Getter functions that expect a NonNull value. 
        ///This offers user to enforce type return by returning error instead of null
        pub fn expectSingle(self: *const Self) !T{
            if(self.singleValue) |val| {
                return val;
            }
            else {
                return ArrayUnionErrors.ExpectingNonNullValue;
            }
        }

        pub fn expectArray(self: *const Self) ![ARRAY_SIZE]T{
            if(self.arrayValue) |val| {
                return val;
            }
            else {
                return ArrayUnionErrors.ExpectingNonNullValue;
            } }


        ///Return boolean values to check state
        pub fn isSingle(self: *const Self) bool {
            return (self.mode == Mode.Single);
        }

        pub fn isArray(self: *const Self) bool {
            return (self.mode == Mode.Array);
        }

        pub fn isInitialized(self: *const Self) bool{
            return (self.mode != Mode.NoValue);
        }

        /// Returns true if the value passed matches either the single or the array value of the ArrayUnion
        /// Can be used to avoid returning error when calling setValue(value).
        pub fn typeMatches(self; *Self, value: anytype) bool {
            if(T == valueType) return true;
            else if (valueTypeInfo == .array and valueTypeInfo.array.child == T and valueTypeInfo.array.len == ARRAY_SIZE) return true;
            else return false;
        }

        pub fn getSingleType(self: *Self)) type {
            return T;
        }

        pub fn getArrayType(self: *Self) type {
            return [ARRAY_SIZE]T;
        }
    };
} 
