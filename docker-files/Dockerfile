FROM registry.opensuse.org/opensuse/leap:15.5
ARG CONTAINER_USERID

RUN zypper ar https://download.opensuse.org/repositories/devel:/languages:/ruby/15.5/ ruby
RUN zypper --gpg-auto-import-keys --non-interactive in --no-recommends ruby3.1-devel "rubygem(bundler)" sudo postgresql-devel make gcc-c++ zlib-devel libxml2-devel libxslt-devel libyaml-devel libffi-devel nodejs libgobject-2_0-0 libvips42 poppler-tools ffmpeg-4 tar xz patch

RUN useradd -g users -p opensuse -d /home/web -m web
RUN echo 'web ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
RUN usermod -u $CONTAINER_USERID web

ADD Gemfile /web/Gemfile
ADD Gemfile.lock /web/Gemfile.lock
RUN chown -R web /web

USER web
WORKDIR /web

ENV BUNDLE_FORCE_RUBY_PLATFORM=true

RUN bundle config build.ffi --enable-system-libffi; \
    bundle config build.nokogiri --use-system-libraries; \
    bundle config build.sassc --disable-march-tune-native; \
    bundle config build.nio4r --with-cflags='-Wno-return-type'

RUN bundle install --jobs=3 --retry=3

CMD ["rails", "server", "-b", "0.0.0.0"]
