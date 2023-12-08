const std = @import("std");

pub fn build(b: *std.Build) !void {
    const root_dir = comptime std.fs.path.dirname(@src().file) orelse ".";
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = std.Build.CompileStep.create(b, .{
        .name = "zstd",
        .kind = .lib,
        .linkage = .static,
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibC();

    const flags: []const []const u8 = switch (lib.target_info.target.os.tag) {
        .windows => base_flags ++ &[_][]const u8{"-D__USE_MINGW_ANSI_STDIO"},
        else => base_flags,
    };
    lib.addCSourceFiles(.{
        .files = sources,
        .flags = flags,
    });
    lib.installHeader(root_dir ++ "/lib/zstd.h", "zstd.h");
    lib.installHeader(root_dir ++ "/lib/zdict.h", "zdict.h");

    b.installArtifact(lib);
}

const base_flags: []const []const u8 = &[_][]const u8{
    "-O3",
    "-Wextra",
    "-Wall",
    "-DZSTD_MULTITHREAD",
};

const sources: []const []const u8 = &absolutePaths([_][]const u8{
    "lib/common/debug.c",
    "lib/common/entropy_common.c",
    "lib/common/error_private.c",
    "lib/common/fse_decompress.c",
    "lib/common/pool.c",
    "lib/common/threading.c",
    "lib/common/xxhash.c",
    "lib/common/zstd_common.c",

    "lib/compress/fse_compress.c",
    "lib/compress/hist.c",
    "lib/compress/huf_compress.c",
    "lib/compress/zstd_compress.c",
    "lib/compress/zstd_compress_literals.c",
    "lib/compress/zstd_compress_sequences.c",
    "lib/compress/zstd_compress_superblock.c",
    "lib/compress/zstd_double_fast.c",
    "lib/compress/zstd_fast.c",
    "lib/compress/zstd_lazy.c",
    "lib/compress/zstd_ldm.c",
    "lib/compress/zstd_opt.c",
    "lib/compress/zstdmt_compress.c",

    "lib/decompress/huf_decompress.c",
    "lib/decompress/huf_decompress_amd64.S",
    "lib/decompress/zstd_ddict.c",
    "lib/decompress/zstd_decompress.c",
    "lib/decompress/zstd_decompress_block.c",

    "lib/dictBuilder/cover.c",
    "lib/dictBuilder/divsufsort.c",
    "lib/dictBuilder/fastcover.c",
    "lib/dictBuilder/zdict.c",

    "lib/legacy/zstd_v01.c",
    "lib/legacy/zstd_v02.c",
    "lib/legacy/zstd_v03.c",
    "lib/legacy/zstd_v04.c",
    "lib/legacy/zstd_v05.c",
    "lib/legacy/zstd_v06.c",
    "lib/legacy/zstd_v07.c",
});

fn absolutePaths(comptime paths: anytype) [paths.len][]const u8 {
    comptime {
        const root_dir = std.fs.path.dirname(@src().file) orelse ".";
        var out_paths: [paths.len][]const u8 = undefined;
        for (paths, 0..) |path, i| {
            out_paths[i] = root_dir ++ "/" ++ path;
        }
        return out_paths;
    }
}
