const std = @import("std");
const lib_zurk = @import("lib_zurk");
const c = lib_zurk.c;

pub const ZurkError = error{
    NullContext,
    InvalidInput,
    KinematicsFailed,
    ContextCreationError,
    UnknownRobotType,
};

pub const RobotType = enum {
    UR3,
    UR5,
    UR10,

    pub fn toC(self: RobotType) c.URtype_C {
        return switch (self) {
            .UR3 => c.UR3,
            .UR5 => c.UR5,
            .UR10 => c.UR10,
        };
    }

    pub fn fromC(c_type: c.URtype_C) !RobotType {
        return switch (c_type) {
            c.UR3 => .UR3,
            c.UR5 => .UR5,
            c.UR10 => .UR10,
            else => error.UnknownRobotType,
        };
    }
};

pub const Pose = struct {
    pos: [3]f32,
    euler_angles: [3]f32,

    pub fn fromC(c_pose: c.pose_C) Pose {
        return .{
            .pos = c_pose.m_pos,
            .euler_angles = c_pose.m_eulerAngles,
        };
    }

    pub fn toC(self: Pose) c.pose_C {
        return .{
            .m_pos = self.pos,
            .m_eulerAngles = self.euler_angles,
        };
    }
};

pub const Robot = struct {
    ctx: *c.UR_C,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, robot_type: RobotType, end_effector: bool, end_effector_dimension: f32) !*Robot {
        const robot = try allocator.create(Robot);
        robot.ctx = c.UR_create(robot_type.toC(), end_effector, end_effector_dimension) orelse return error.ContextCreationError;
        robot.allocator = allocator;
        return robot;
    }

    pub fn deinit(self: *Robot) void {
        c.UR_destroy(self.ctx);
        self.allocator.destroy(self);
    }

    pub fn forwardKinematics(self: *const Robot, joint_angles: [c.UR_NUM_DOF]f32) Pose {
        var tcp_pose: c.pose_C = undefined;
        c.UR_forwardKinematics(self.ctx, &joint_angles, &tcp_pose);
        return Pose.fromC(tcp_pose);
    }

    pub fn inverseKinematics(self: *const Robot, target_tip_pose: Pose) [c.UR_NUM_IK_SOLUTIONS * c.UR_NUM_DOF]f32 {
        var solved_joint_angles: [c.UR_NUM_IK_SOLUTIONS * c.UR_NUM_DOF]f32 = undefined;
        const c_pose = target_tip_pose.toC();
        c.UR_inverseKinematics(self.ctx, &c_pose, &solved_joint_angles);
        return solved_joint_angles;
    }

    pub fn getRobotType(self: *const Robot) !RobotType {
        const c_type = c.UR_getRobotType(self.ctx);
        return RobotType.fromC(c_type);
    }
};

pub const mathLib = struct {
    pub const rad = c.mathLib_rad;
    pub const deg = c.mathLib_deg;
};