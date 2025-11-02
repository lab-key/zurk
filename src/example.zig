const std = @import("std");
const zurk = @import("zurk");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const robot = try zurk.Robot.init(allocator, .UR5, false, 0.0);
    defer robot.deinit();

    std.debug.print("URK Context created successfully!\n", .{});

    // Example: Forward Kinematics
    const joint_angles: [6]f32 = .{ 0.0, -std.math.pi / 2.0, 0.0, -std.math.pi / 2.0, 0.0, 0.0 };
    const tcp_pose = robot.forwardKinematics(joint_angles);

    std.debug.print("Running Forward Kinematics...\n", .{});
    std.debug.print("TCP Position: {d}, {d}, {d}\n", .{ tcp_pose.pos[0], tcp_pose.pos[1], tcp_pose.pos[2] });
    std.debug.print("TCP Euler Angles: {d}, {d}, {d}\n", .{ tcp_pose.euler_angles[0], tcp_pose.euler_angles[1], tcp_pose.euler_angles[2] });

    // Example: Inverse Kinematics
    const target_pose: zurk.Pose = .{
        .pos = .{ 0.0, 0.0, 0.5 },
        .euler_angles = .{ 0.0, 0.0, 0.0 },
    };
    const solved_joint_angles = robot.inverseKinematics(target_pose);

    std.debug.print("Running Inverse Kinematics...\n", .{});
    std.debug.print("Solved Joint Angles: {d}, {d}, {d}, {d}, {d}, {d}\n", .{ solved_joint_angles[0], solved_joint_angles[1], solved_joint_angles[2], solved_joint_angles[3], solved_joint_angles[4], solved_joint_angles[5] });

    // Example: mathLib functions
    const degree_val: f32 = 90.0;
    const rad_val = zurk.mathLib.rad(degree_val);
    const deg_val = zurk.mathLib.deg(rad_val);

    std.debug.print("\nmathLib Examples:\n", .{});
    std.debug.print("  {d} degrees is {d:.4} radians\n", .{ degree_val, rad_val });
    std.debug.print("  {d:.4} radians is {d:.4} degrees\n", .{ rad_val, deg_val });

    // Example: Get Robot Type
    const robot_type = try robot.getRobotType();
    switch (robot_type) {
        .UR3 => std.debug.print("Robot Type: UR3\n", .{}),
        .UR5 => std.debug.print("Robot Type: UR5\n", .{}),
        .UR10 => std.debug.print("Robot Type: UR10\n", .{}),
    }

    std.debug.print("Zurk example finished successfully!\n", .{});
}