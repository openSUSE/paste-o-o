FROM registry.opensuse.org/opensuse/leap:latest
ARG CONTAINER_USERID

RUN mkdir -p /bundler/vendor
RUN zypper ar https://download.opensuse.org/repositories/devel:/languages:/ruby/\$releasever/ ruby
# TODO: remove after https://src.opensuse.org/openSUSE/Leap/issues/162
RUN zypper ar https://download.opensuse.org/repositories/graphics/\$releasever graphics
RUN zypper --gpg-auto-import-keys --non-interactive in --no-recommends ruby3.4-devel "rubygem(bundler)" sudo postgresql-devel make gcc-c++ zlib-devel libvips-devel libxml2-devel libxslt-devel libffi-devel libyaml-devel nodejs libgobject-2_0-0 poppler-tools ffmpeg-4 shared-mime-info

RUN useradd -g users -p opensuse -d /home/web -m web
RUN echo 'web ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
RUN usermod -u $CONTAINER_USERID web

ADD Gemfile /web/Gemfile
ADD Gemfile.lock /web/Gemfile.lock
RUN chown web /web /bundler/vendor

USER web
WORKDIR /web

ENV BUNDLE_FORCE_RUBY_PLATFORM=true

RUN set -efu ; \
    bundle config build.ffi --enable-system-libffi; \
    bundle config build.nokogiri --use-system-libraries; \
    bundle config build.sassc --disable-march-tune-native; \
    bundle config build.nio4r --with-cflags='-Wno-return-type';\
    bundle config set --global path /bundler/vendor

RUN bundle install --jobs=3 --retry=3

CMD ["bin/rails", "server", "-b", "0.0.0.0"]
