FROM arch-buildenv-zest

COPY mruby-zest-build mruby-zest-build

WORKDIR mruby-zest-build

RUN make
