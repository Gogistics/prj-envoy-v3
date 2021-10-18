# Filters
Envoy is one of powerful proxies nowadays, especially popular in service mesh and edge computing. By default, Envoy has a rich set of APIs that let users and control plane to statically and dynamically configure itself. Furthermore, Envoy allows users to customize filters to handle different use cases and enhance the security. With a combination of different filters, Envoy is able to transform and perform higher order access control operations. Currently, Envoy provides 3 types of filters positioned in a hierarchical filter chain.

- Listener Filters
- Network Filters
- HTTP Filters

Ref:
- [Extending Envoy for custom use cases](https://www.envoyproxy.io/docs/envoy/latest/extending/extending)
- [Envoy filter example](https://github.com/envoyproxy/envoy-filter-example)

## Customize http filter (WIP)

### Prerequisites for Mac Developers
* Xcode
* cMake
* ninja
* Bazel

Ref:
- [cMake](https://formulae.brew.sh/formula/cmake)
- [ninja](https://formulae.brew.sh/formula/ninja)
- [XCode](https://stackoverflow.com/questions/17980759/xcode-select-active-developer-directory-error)

Possible issues:
- [xcode-select active developer directory error](https://stackoverflow.com/questions/17980759/xcode-select-active-developer-directory-error)
- [bazel "undeclared inclusion(s)" error](https://stackoverflow.com/questions/43921911/how-to-resolve-bazel-undeclared-inclusions-error)

## Development Steps

### Compile Envoy from strach
1. Write Bazel files properly; read comments in the Bazel files for references. Assume that all prerequisites have been installed, the sbumodule has been added and all Bazel files are configured properly.
```sh
# build envoy bin by Bazel
$  bazel build //filters:envoy
```

Ref:
- [Building](https://www.envoyproxy.io/docs/envoy/latest/start/building.html)
- [Building an Envoy Docker image](envoyproxy.io/docs/envoy/latest/start/building/local_docker_build)
- [Building Envoy with Bazel](https://github.com/envoyproxy/envoy/blob/bebd3e2c4700fb13132a34fcfa8b82b439249f3b/bazel/README.md)

2. Create certs

```sh
$ cd utils/

$ openssl genrsa -out certs/ca.key 4096
# Generating RSA private key, 4096 bit long modulus
# ..................................................................................................................................................................................................++
# ...........................................................................................................................++
# e is 65537 (0x10001)

$ openssl req -x509 -new -nodes -key certs/ca.key -sha256 -days 1024 -out certs/ca.crt

$ openssl genrsa -out certs/atai-filter.com.key 2048
# Generating RSA private key, 2048 bit long modulus
# ...+++
# ......................................+++
# e is 65537 (0x10001)

$ openssl req -new -sha256 \
    -key certs/atai-filter.com.key \
    -subj "/C=US/ST=CA/O=GOGISTICS, Inc./CN=atai-filter.com" \
    -out certs/atai-filter.com.csr

$ openssl x509 -req \
     -in certs/atai-filter.com.csr \
     -CA certs/ca.crt \
     -CAkey certs/ca.key \
     -CAcreateserial \
     -extfile <(printf "subjectAltName=DNS:atai-filter.com") \
     -out certs/atai-filter.com.crt \
     -days 500 \
     -sha256
```

3. Build container running Envoy
Issues:
- [envoy su-exec: envoy: Exec format error](https://discuss.istio.io/t/how-to-build-istio-proxy-image-on-mac/2104)
- [Compile Envoy on Raspberry Pi4](https://stevesloka.com/compile-envoy-on-raspberry-pi4/)


```sh
$ bazel build //filters:envoy --jobs=3 -c opt --config=remote-clang \
    --remote_cache=grpcs://remotebuildexecution.googleapis.com \
    --remote_executor=grpcs://remotebuildexecution.googleapis.com \
    --remote_instance_name=projects/envoy-ci/instances/default_instance

$ bazel build //filters:envoy --jobs=3 --config=docker-clang
# test
$ docker run -d \
      --name atai_envoy_with_custom_filters \
      -p 80:80 -p 443:443 -p 8001:8001 \
      --network atai_filter \
      --ip "175.10.0.5" \
      --log-opt mode=non-blocking \
      --log-opt max-buffer-size=5m \
      --log-opt max-size=100m \
      --log-opt max-file=5 \
      alantai/prj-envoy-v3/envoy:v0.0.0

docker run --rm -it \
      -v $(pwd)/utils/configs/front-envoy-config-test.yaml:/envoy-custom.yaml \
      -p 9901:9901 \
      -p 10000:10000 \
      envoyproxy/envoy-dev:14a052a5dfc808a03c966365540514a98d711abc \
          -c /envoy-custom.yaml

https://github.com/Kitware/CMake/releases/download/v3.21.3/cmake-3.21.3.tar.gz
```

TMP (remove later)
```sh
$ docker run --rm -v $(pwd):/app -w /app gcc:11 sh -c "g++ -Wall -o hello hello_world.cpp && ./hello"
$ docker run --rm -v $(pwd):/app -w /app gcc:11 sh -c "gcc -Wall -o hello hello_world.c && ./hello"
```