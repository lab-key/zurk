const c = @import("c.zig");
const std = @import("std");

// Re-export core types for convenience
pub const Vec3 = c.Vec3;
pub const Quat = c.Quat;
pub const IkRet = c.IkRet;
pub const LogSeverity = c.LogSeverity;
pub const Algorithm = c.Algorithm;
pub const SolverFlags = c.SolverFlags;
pub const ConstraintType = c.ConstraintType;
pub const EffectorFlags = c.EffectorFlags;

// Re-export the main IKAPI for direct access if needed, similar to zmujoco.zig's `pub const c = lib_zmujoco.c;`
pub const IKAPI = c.IKAPI;

// Example of wrapping a C function from c.IKAPI.vec3
pub fn vec3(x: f64, y: f64, z: f64) Vec3 {
    return c.IKAPI.vec3.vec3(x, y, z);
}

// Example of wrapping a C function from c.IKAPI.log
// This is a more complex wrapper due to variadic arguments and Zig's comptime formatting.
// It would involve formatting the message in Zig and then passing the resulting string to the C function.
// For now, a direct call for non-variadic functions is simpler.
// For variadic functions like `message`, we might need a helper C function or a more involved Zig wrapper.
// For simplicity, let's assume a direct call for now, but note the complexity.
// pub fn logMessage(severity: LogSeverity, comptime fmt: []const u8, args: anytype) void {
//     // This won't work directly with Zig's comptime fmt
//     @compileError("Variadic functions like logMessage require a more sophisticated wrapper.");
// }
// For now, let's provide a simpler wrapper for log messages without variadic args,
// or a direct call to the C function if it's not variadic.
// Since c.IKAPI.log.message is variadic, we'll need to handle it carefully.
// For the initial wrapper, we can expose a simpler log function or skip variadic ones.
// Let's provide a basic wrapper for `set_severity` and `init`/`deinit` for now.

pub fn logInit() IkRet {
    return c.IKAPI.log.init();
}

pub fn logDeinit() void {
    c.IKAPI.log.deinit();
}

pub fn logSetSeverity(severity: LogSeverity) void {
    c.IKAPI.log.set_severity(severity);
}

// Example of wrapping a C function from c.IKAPI.solver
pub fn createSolver(algorithm: Algorithm) ?*c.ik_solver_t {
    return c.IKAPI.solver.create(algorithm);
}

// Example of wrapping a C function from c.IKAPI.node
pub fn createNode(guid: u32) ?*c.ik_node_t {
    return c.IKAPI.node.create(guid);
}

// ... and so on for other functions in IKAPI and its nested interfaces.
// Each `pub fn` in zik.zig would typically call `c.IKAPI.<interface>.<function_name>(...)`
// and handle any necessary type conversions or error checking.
