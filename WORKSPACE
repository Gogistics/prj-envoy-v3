workspace(name = "atai-filters")

# https://docs.bazel.build/versions/main/be/workspace.html#local_repository
local_repository(
    name = "envoy",
    path = "official-envoy", # directory name of the submodule which contains the official resources
)

# load functions from envoy
load("@envoy//bazel:api_binding.bzl", "envoy_api_binding")
envoy_api_binding()

load("@envoy//bazel:api_repositories.bzl", "envoy_api_dependencies")
envoy_api_dependencies()

load("@envoy//bazel:repositories.bzl", "envoy_dependencies")
envoy_dependencies()

load("@envoy//bazel:repositories_extra.bzl", "envoy_dependencies_extra")
envoy_dependencies_extra()

load("@envoy//bazel:dependency_imports.bzl", "envoy_dependency_imports")
envoy_dependency_imports()

# load tools
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# download docker rules
http_archive(
    name = "io_bazel_rules_docker",
    sha256 = "59d5b42ac315e7eadffa944e86e90c2990110a1c8075f1cd145f487e999d22b3",
    strip_prefix = "rules_docker-0.17.0",
    urls = ["https://github.com/bazelbuild/rules_docker/releases/download/v0.17.0/rules_docker-v0.17.0.tar.gz"],
)
load(
    "@io_bazel_rules_docker//repositories:repositories.bzl",
    container_repositories = "repositories",
)
container_repositories()

load("@io_bazel_rules_docker//repositories:deps.bzl", container_deps = "deps")
container_deps()

load("@io_bazel_rules_docker//container:pull.bzl", "container_pull")
container_pull(
    name = "alpine_envoy",
    digest = "sha256:bddd3e2e72c5e8efd5cb862054bb55cd04b4211cabe74c5308d2054743c614ca",
    registry = "index.docker.io",
    repository = "envoyproxy/envoy-alpine",
)

container_pull(
    name = "alpine_envoy_base",
    digest = "sha256:f7ea503a3bcfb722d52a8cbbb12e74ea25efdfb8a250355a90e83f18018189f9",
    registry = "index.docker.io",
    repository = "frolvlad/alpine-glibc",
)

# protobuf
http_archive(
    name = "com_google_protobuf",
    sha256 = "9748c0d90e54ea09e5e75fb7fac16edce15d2028d4356f32211cfa3c0e956564",
    strip_prefix = "protobuf-3.11.4",
    urls = ["https://github.com/protocolbuffers/protobuf/archive/v3.11.4.zip"],
)

load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")

protobuf_deps()
# \protobuf

# load rules_cc
http_archive(
    name = "rules_cc",
    urls = ["https://github.com/bazelbuild/rules_cc/archive/TODO"],
    sha256 = "TODO",
)

load("@rules_cc//cc:repositories.bzl", "rules_cc_dependencies", "rules_cc_toolchains")

rules_cc_dependencies()

rules_cc_toolchains()
