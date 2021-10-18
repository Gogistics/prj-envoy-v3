#!/bin/sh

# place certs in the right directories and run envoy against the config file
apk add --update --no-cache ca-certificates shadow su-exec &&
    addgroup -S envoy && adduser --no-create-home -S envoy -G envoy &&
    mkdir -p /etc/envoy/certs/ &&
    cp atai-filter.com.crt atai-filter.com.key /etc/envoy/certs/ &&
    chmod 744 /etc/envoy/certs/* &&
    mkdir -p /usr/local/share/ca-certificates/extra/ &&
    cp atai-filter.com.crt /usr/local/share/ca-certificates/ &&
    cat /usr/local/share/ca-certificates/atai-filter.com.crt >> /etc/ssl/certs/ca-certificates.crt &&
    cp custom-ca-certificates.crt /usr/local/share/ca-certificates/ &&
    cp custom-ca-certificates.crt /usr/local/share/ca-certificates/extra/ &&
    update-ca-certificates &&
    chmod go+r /front-envoy-config.yaml &&
    # todo: fix bug
    # copy custom envoy to /usr/local/bin
    cp envoy /usr/local/bin/ &&
    envoy -c /front-envoy-config.yaml