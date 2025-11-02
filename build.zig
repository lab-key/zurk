const std = @import("std");

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const lib_zurk_dep = b.dependency("lib_zurk", .{
        .target = target,
        .optimize = optimize,
    });

    const lib_zurk_module = lib_zurk_dep.module("lib_zurk");

    const options = .{
        .use_single_precision = b.option(
            bool,
            "use_single_precision",
            "Use single precision (float) for mjtNum instead of double",
        ) orelse false,
    };

    const options_step = b.addOptions();
    inline for (std.meta.fields(@TypeOf(options))) |field| {
        options_step.addOption(field.type, field.name, @field(options, field.name));
    }
    const options_module = options_step.createModule();

    // Create the zurk wrapper module
    const zurk_module = b.createModule(.{
        .root_source_file = b.path("src/zurk.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "zmujoco_options", .module = options_module },
            .{ .name = "lib_zurk", .module = lib_zurk_module },
        },
    });

    // Export the zurk module so other packages can import it
    b.modules.put("zurk", zurk_module) catch @panic("failed to register zurk module");

    // --- Build an example executable --- 
    const example_exe = b.addExecutable(.{
        .name = "zurk_example",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/example.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{ 
                .{ .name = "zurk", .module = zurk_module },
            },
        }),
    });

    b.installArtifact(example_exe);

    const run_example_step = b.addRunArtifact(example_exe);
    const run_step = b.step("run", "Run the universalRobotsKinematics example");
    run_step.dependOn(&run_example_step.step);
}
