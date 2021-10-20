# Filters
Envoy is one of powerful proxies nowadays, especially popular in service mesh and edge computing. By default, Envoy has a rich set of APIs that let users and control plane to statically and dynamically configure itself. Furthermore, Envoy allows users to customize filters to handle different use cases and enhance the security. With a combination of different filters, Envoy is able to transform and perform higher order access control operations. Currently, Envoy provides 3 types of filters positioned in a hierarchical filter chain.

- Listener Filters
- Network Filters
- HTTP Filters

Ref:
- [Extending Envoy for custom use cases](https://www.envoyproxy.io/docs/envoy/latest/extending/extending)
- [Envoy filter example](https://github.com/envoyproxy/envoy-filter-example)

## Customize http filter (WIP)
Now, I'm using the exmaple from Envoy official project to demo how to write and build custom Envoy filter on Mac and Ubuntu. Later, I'll come out with other use cases of custom Envoy filters. If you want to run the compiled Envoy in Docker container, I suggest writing and building Envoy filter on Linux. 

### Prerequisites for Mac Developers
* App Store: Xcode
* Homebrew: coreutils wget cmake libtool go bazel automake ninja clang-format autoconf aspell

Ref:
- [cMake](https://formulae.brew.sh/formula/cmake)
- [ninja](https://formulae.brew.sh/formula/ninja)
- [XCode](https://stackoverflow.com/questions/17980759/xcode-select-active-developer-directory-error)

Possible issues:
- [xcode-select active developer directory error](https://stackoverflow.com/questions/17980759/xcode-select-active-developer-directory-error)
- [bazel "undeclared inclusion(s)" error](https://stackoverflow.com/questions/43921911/how-to-resolve-bazel-undeclared-inclusions-error)


### Steps of compiling Envoy with custom filter from strach
1. Write Bazel files. Read comments in Bazel files for references. Assume that all prerequisites have been installed, the sbumodule has been added and all Bazel files are configured properly.

```sh
# checkout submodule which is the official Envoy repository
$ git submodule update --init --recursive

# if you encounter version issue, you might need to manually checkout other stable version
# check current tags
$ git describe --tags

# fetch all tags
$ git fetch --tags

# get latest tag name
$ latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)

# checkout
$ git checkout $latestTag

# build envoy bin by Bazel
$  bazel build -c opt //filters:envoy
```

Ref:
- [Building Envoy with Bazel](https://github.com/envoyproxy/envoy/tree/main/bazel)
- [Building](https://www.envoyproxy.io/docs/envoy/latest/start/building.html)
- [Building an Envoy Docker image](envoyproxy.io/docs/envoy/latest/start/building/local_docker_build)
- [Building Envoy with Bazel](https://github.com/envoyproxy/envoy/blob/bebd3e2c4700fb13132a34fcfa8b82b439249f3b/bazel/README.md)

2. Create certs (optional)
If you want to enable TLS, you need to generate certs before building Docker image.

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
If you build custom Envoy on Mac, you would get **envoy su-exec: envoy: Exec format error**.

Ref:
- [Compile Envoy on Raspberry Pi4](https://stevesloka.com/compile-envoy-on-raspberry-pi4/)

Issues:
- [su-exec: envoy: Exec format error](https://discuss.istio.io/t/how-to-build-istio-proxy-image-on-mac/2104)

```sh
# build Docker image
$ cp bazel-bin/filters/envoy utils/build_envoy_release_stripped/envoy
$ docker build -t alantai/prj-envoy-v3:atai-envoy-v0.0.0 -f utils/dockerfiles/Dockerfile-envoy-alpine .
$ docker scan alantai/prj-envoy-v3:atai-envoy-v0.0.0 

# once the envoy
$ docker run -d \
      --name atai_envoy_with_custom_filters \
      -p 80:80 -p 443:443 -p 8001:8001 \
      --network atai_filter \
      --ip "175.10.0.5" \
      --log-opt mode=non-blocking \
      --log-opt max-buffer-size=5m \
      --log-opt max-size=100m \
      --log-opt max-file=5 \
      alantai/prj-envoy-v3:atai-envoy-v0.0.0
```