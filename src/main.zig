const std = @import("std");
const clay = @import("clay");
const raylib = @import("raylib");
const raylib_renderer = clay.renderers.raylib;

var debug_enabled = false;
const font_id_body_24 = 0;
const font_id_body_16 = 1;

inline fn vectorConvert(vector: raylib.Vector2) clay.Vector2 {
    return .{ .x = vector.x, .y = vector.y };
}

inline fn colorConvert(color: raylib.Color) clay.Color {
    return clay.Color.rgba(u8, color.r, color.g, color.b, color.a);
}

fn createLayout() []clay.RenderCommand {
    clay.beginLayout();
    clay.ui()(.{
        .id = clay.id("outer"),
        .layout = .{
            .sizing = clay.Element.Sizing.grow(.{}),
            .padding = clay.Padding.all(16),
            .child_gap = 16,
        },
        .rectangle = .{ .color = .{ .r = 200, .g = 200, .b = 200 } },
    })({
        clay.ui()(.{
            .id = clay.id("inner"),
            .layout = .{
                .sizing = clay.Element.Sizing.grow(.{}),
                .padding = clay.Padding.all(8),
            },
            .rectangle = .{ .color = .{ .r = 22, .g = 22, .b = 30 } },
        })({
            clay.text("test", .{
                .color = .{ .r = 255, .g = 255, .b = 255, .a = 255 },
                .font_size = 16,
            });
        });
    });

    return clay.endLayout();
}

fn update(allocator: std.mem.Allocator) void {
    const mouse_position: clay.Vector2 = vectorConvert(raylib.getMousePosition());
    clay.setPointerState(mouse_position, raylib.isMouseButtonDown(raylib.MouseButton.left));
    
    // optional, default is esc
    raylib.setExitKey(raylib.KeyboardKey.q);

    if (raylib.isKeyPressed(raylib.KeyboardKey.d)) {
        debug_enabled = !debug_enabled;
        clay.setDebugModeEnabled(debug_enabled);
    }
    
    clay.setLayoutDimensions(.{
        .width = @floatFromInt(raylib.getScreenWidth()),
        .height = @floatFromInt(raylib.getScreenHeight()),
    });
    
    raylib.beginDrawing();
    raylib.clearBackground(raylib.Color.black);
    raylib_renderer.render(createLayout(), allocator);
    raylib.endDrawing();
}

pub fn main() !void {
    clay.setMaxElementCount(8192);
    const memory_size = clay.minMemorySize();
    const arena = clay.createArena(std.heap.c_allocator, memory_size);
    std.debug.print("{d}\n", .{memory_size});
    
    clay.setMeasureTextFunction(raylib_renderer.measureText);
    _ = clay.initialize(
        arena,
        .{
            .width = @floatFromInt(raylib.getScreenWidth()),
            .height = @floatFromInt(raylib.getScreenHeight()),
        },
        .{},
    );
    raylib_renderer.initialize(640, 480, "Clay - Raylib Renderer Example in Zig", .{
        .vsync_hint = true,
        .window_resizable = true,
        .msaa_4x_hint = true,
    });

    // required to display any text, including debug mode
    {
        const font = try raylib.loadFontEx("src/resources/Roboto-Regular.ttf", 48, null);
        raylib.setTextureFilter(font.texture, .bilinear);
        raylib_renderer.addFont(font_id_body_24, font);
    }
    {
        const font = try raylib.loadFontEx("src/resources/Roboto-Regular.ttf", 32, null);
        raylib.setTextureFilter(font.texture, .bilinear);
        raylib_renderer.addFont(font_id_body_16, font);
    }

    while (!raylib.windowShouldClose()) {
        update(std.heap.c_allocator);
    }
}
