# ArrayUnion

A generic Zig library that provides a unified interface for fields that can be either single values or arrays of the same type.

## Why ArrayUnion?

When building applications, you often need fields that can work in two modes:
- **Uniform mode**: One value applied to all items (e.g., all tiles have the same color)
- **Individual mode**: Different values for each item (e.g., each tile has its own color)

Without ArrayUnion, you'd need to create separate union types for each field:

```zig
// The old way - lots of repetitive unions
const Config = struct {
    color: union(enum) { single: Color, array: [N]Color },
    speed: union(enum) { single: f32, array: [N]f32 },
    size: union(enum) { single: f32, array: [N]f32 },
    // ... and so on for every field
};

// Each field needs its own handling logic
switch (config.color) {
    .single => |c| applyColorToAll(c),
    .array => |arr| for (arr, 0..) |c, i| applyColor(i, c),
}
```

With ArrayUnion, you get a consistent interface:

```zig
// The ArrayUnion way - clean and consistent
const Config = struct {
    color: ArrayUnion(Color, N),
    speed: ArrayUnion(f32, N),
    size: ArrayUnion(f32, N),
};

// Same handling pattern for all fields
if (config.color.getSingleValue()) |c| applyColorToAll(c);
if (config.color.getArrayValue()) |arr| for (arr, 0..) |c, i| applyColor(i, c);
```

## Installation

### Using Zig Package Manager

Add to your `build.zig.zon`:

```zig
.dependencies = .{
    .arrayunion = .{
        .url = "https://github.com/austinrtn/zig_arrayunion",
        .hash = "...", // Will be auto-generated
    },
},
```

Add to your `build.zig`:

```zig
const arrayunion = b.dependency("arrayunion", .{});
exe.root_module.addImport("arrayunion", arrayunion.module("arrayunion"));
```

### Manual Installation

1. Download the source
2. Copy `src/` to your project
3. Import with `@import("path/to/src/main.zig")`

## Basic Usage

```zig
const std = @import("std");
const arrayunion = @import("arrayunion");
const ArrayUnion = arrayunion.ArrayUnion;

// Create an ArrayUnion that can hold either one i32 or an array of 5 i32s
const IntUnion = ArrayUnion(i32, 5);

pub fn main() !void {
    var config = IntUnion{};
    
    // Set a single value (uniform mode)
    try config.setValue(42);
    std.debug.print("Is single: {}\n", .{config.isSingle()}); // true
    
    if (config.getSingleValue()) |value| {
        std.debug.print("Single value: {}\n", .{value}); // 42
    }
    
    // Set an array (individual mode)
    const values = [_]i32{10, 20, 30, 40, 50};
    try config.setValue(values);
    std.debug.print("Is array: {}\n", .{config.isArray()}); // true
    
    if (config.getArrayValue()) |arr| {
        for (arr) |val| {
            std.debug.print("{} ", .{val}); // 10 20 30 40 50
        }
    }
}
```

## API Reference

### Creating an ArrayUnion

```zig
const MyUnion = ArrayUnion(DataType, ArraySize);
var instance = MyUnion{};
```

### Setting Values

```zig
// Generic setter - detects type automatically
try instance.setValue(single_value);      // Sets single mode
try instance.setValue([_]T{...});         // Sets array mode

// Specific setters - never return errors
instance.setSingleValue(value);           // Direct single value
instance.setArrayValue([_]T{...});        // Direct array value
instance.fillArray(value);                // Fill entire array with one value
```

### Getting Values (Safe)

```zig
// Returns optional - safe access
const maybe_single = instance.getSingleValue();  // ?T
const maybe_array = instance.getArrayValue();    // ?[N]T

if (maybe_single) |value| {
    // Handle single value
}
```

### Getting Values (Assertive)

```zig
// Returns error if wrong type - use when you're confident
const value = try instance.expectSingle();       // !T
const array = try instance.expectArray();        // ![N]T
```

### Checking State

```zig
const is_single = instance.isSingle();           // bool
const is_array = instance.isArray();             // bool
const is_initialized = instance.isInitialized(); // bool
```

## Common Patterns

### Configuration Objects

```zig
const GameConfig = struct {
    player_speed: ArrayUnion(f32, MAX_PLAYERS),
    player_color: ArrayUnion(Color, MAX_PLAYERS),
    player_size: ArrayUnion(f32, MAX_PLAYERS),
    
    pub fn applyToPlayer(self: *const @This(), player_id: usize) PlayerSettings {
        return PlayerSettings{
            .speed = self.player_speed.getSingleValue() orelse self.player_speed.getArrayValue().?[player_id],
            .color = self.player_color.getSingleValue() orelse self.player_color.getArrayValue().?[player_id],
            .size = self.player_size.getSingleValue() orelse self.player_size.getArrayValue().?[player_id],
        };
    }
};
```

### Generic Processing

```zig
fn processField(field: anytype, processor: anytype) void {
    if (field.isSingle()) {
        const val = field.expectSingle() catch return;
        // Apply same value to all items
        for (0..field.array_size) |i| processor(i, val);
    } else if (field.isArray()) {
        const arr = field.expectArray() catch return;
        // Apply individual values
        for (arr, 0..) |val, i| processor(i, val);
    }
}

// Works with any ArrayUnion
processField(config.speed, applySpeed);
processField(config.color, applyColor);
```

### Convenience Functions

The library provides helper functions for common initialization patterns:

```zig
// Create with single value
var single_config = arrayunion.createSingle(f32, 10, 1.5);

// Create with array
const values = [_]f32{1.0, 1.5, 2.0, 2.5, 3.0};
var array_config = arrayunion.createArray(f32, 5, values);

// Create array filled with one value
var filled_config = arrayunion.createArrayAndFill(f32, 10, 2.0);
```

## Error Handling

ArrayUnion defines these errors:

- `ArrayUnionErrors.TypeMismatch`: Passed wrong type to `setValue()`
- `ArrayUnionErrors.ExpectingNonNullValue`: Called `expectSingle()`/`expectArray()` on wrong type

```zig
// Handle errors appropriately
config.setValue("wrong_type") catch |err| switch (err) {
    ArrayUnionErrors.TypeMismatch => std.debug.print("Wrong type!\n", .{}),
};

const value = config.expectSingle() catch |err| switch (err) {
    ArrayUnionErrors.ExpectingNonNullValue => {
        std.debug.print("No single value set!\n", .{});
        return default_value;
    },
};
```

## Building and Testing

```bash
# Run tests
zig build test

# Build and run example
zig build run-example

# Just build example
zig build example
```

## Use Cases

- **Game Development**: Player properties that can be uniform or per-player
- **Graphics**: Rendering properties that apply globally or per-element
- **Configuration**: Settings that work in "simple mode" or "advanced mode"
- **UI Systems**: Styling that can be consistent or customized per-component
- **Data Processing**: Algorithms that handle both scalar and vector inputs

## Contributing

Contributions welcome! Please ensure:
- All tests pass (`zig build test`)
- Code follows Zig style conventions
- New features include tests and documentation

## License

[Your License Here]

## Version

Current version: 0.1.0

Compatible with Zig 0.13.0+
