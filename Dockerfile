# https://github.com/moby/moby/issues/37345#issuecomment-400245466
ARG install_dir=/usr/src/wrt-install
ARG wrk_version=4.2.0

FROM alpine as compile-stage

ARG install_dir
ARG wrk_version
ENV wrk_version=${wrk_version}

WORKDIR /usr/src

RUN apk add build-base perl linux-headers openssl-dev

# https://github.com/wg/wrk/tags
ADD https://github.com/wg/wrk/archive/${wrk_version}.tar.gz /usr/src

RUN tar -xf ${wrk_version}.tar.gz && \
  cd wrk-${wrk_version} && \
  # Compile wrk
  make \
  VER=${wrk_version} && \
  # Create directory structure to copy to scratch image
  install -Dm755 wrk "${install_dir}/usr/bin/wrk" ; \
  install -Dm644 LICENSE "${install_dir}"/usr/share/licenses/wrk/LICENSE ; \
  install -Dm644 NOTICE "${install_dir}"/usr/share/licenses/wrk/NOTICE ; \
  install -d -m755 "${install_dir}"/usr/share/doc/wrk/examples/ ; \
  install -Dm644 README.md "${install_dir}"/usr/share/doc/wrk/README ; \
  install -Dm644 SCRIPTING "${install_dir}"/usr/share/doc/wrk/SCRIPTING ; \
  install -Dm644 CHANGES "${install_dir}"/usr/share/doc/wrk/CHANGES ; \
  install -Dm644 scripts/*.lua "${install_dir}"/usr/share/doc/wrk/examples/

FROM alpine

ARG install_dir
ARG wrk_version
ENV wrk_version=${wrk_version}

RUN apk update && apk add --no-cache libgcc

VOLUME /scripts

COPY --from=compile-stage ${install_dir} /

ENTRYPOINT [ "/usr/bin/wrk" ]
CMD ["-v"]
