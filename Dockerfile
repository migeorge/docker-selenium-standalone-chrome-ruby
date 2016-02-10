FROM selenium/standalone-chrome:2.50.0

MAINTAINER Mike George <mike@tallduck.com>

USER root

RUN apt-get update \
 && apt-get install -y --force-yes --no-install-recommends \
      build-essential \
      bzip2 \
      ca-certificates \
      curl \
      dpkg-dev \
      gcc \
      libbz2-1.0=1.0.6-7 \
      libdpkg-perl \
      libffi-dev \
      libgdbm3 \
      libssl-dev \
      libtimedate-perl \
      libyaml-dev \
      netbase \
      perl \
      perl-base=5.20.2-2ubuntu0.1 \
      procps \
      zlib1g-dev \
      zlib1g=1:1.2.8.dfsg-2ubuntu1

# skip installing gem documentation
RUN mkdir -p /usr/local/etc \
 && { \
   echo 'install: --no-document'; \
   echo 'update: --no-document'; \
 } >> /usr/local/etc/gemrc

ENV RUBY_MAJOR 2.3
ENV RUBY_VERSION 2.3.0
ENV RUBY_DOWNLOAD_SHA256 ba5ba60e5f1aa21b4ef8e9bf35b9ddb57286cb546aac4b5a28c71f459467e507
ENV RUBYGEMS_VERSION 2.5.2

# some of ruby's build scripts are written in ruby
# we purge this later to make sure our final image uses what we just built
RUN set -ex \
  && buildDeps=' \
    ruby \
  ' \
  && apt-get update \
  && apt-get install -y --force-yes --no-install-recommends $buildDeps \
    autoconf \
    bison \
    gcc \
    libbz2-dev \
    libgdbm-dev \
    libglib2.0-dev \
    libncurses-dev \
    libncurses5=5.9+20140712-2ubuntu2 \
    libncursesw5=5.9+20140712-2ubuntu2 \
    libpcre3-dev \
    libpcre3=2:8.35-3.3ubuntu1.1 \
    libpython-stdlib \
    libpython2.7-stdlib \
    libreadline-dev \
    libreadline6-dev \
    libtinfo-dev=5.9+20140712-2ubuntu2 \
    libtinfo5=5.9+20140712-2ubuntu2 \
    libxml2-dev \
    libxslt-dev \
    make \
    ncurses-bin=5.9+20140712-2ubuntu2 \
    python \
    python2.7 \
  && rm -rf /var/lib/apt/lists/* \
  && curl -fSL -o ruby.tar.gz "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.gz" \
  && echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.gz" | sha256sum -c - \
  && mkdir -p /usr/src/ruby \
  && tar -xzf ruby.tar.gz -C /usr/src/ruby --strip-components=1 \
  && rm ruby.tar.gz \
  && cd /usr/src/ruby \
  && { echo '#define ENABLE_PATH_CHECK 0'; echo; cat file.c; } > file.c.new && mv file.c.new file.c \
  && autoconf \
  && ./configure --disable-install-doc \
  && make -j"$(nproc)" \
  && make install \
  && apt-get purge -y $buildDeps \
  && gem update --system $RUBYGEMS_VERSION \
  && rm -r /usr/src/ruby

ENV BUNDLER_VERSION 1.11.2

RUN gem install bundler --version "$BUNDLER_VERSION"

# install things globally, for great justice
# and don't create ".bundle" in all our apps
ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_PATH="$GEM_HOME" \
  BUNDLE_BIN="$GEM_HOME/bin" \
  BUNDLE_SILENCE_ROOT_WARNING=1 \
  BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $BUNDLE_BIN:$PATH
RUN mkdir -p "$GEM_HOME" "$BUNDLE_BIN" \
  && chmod 777 "$GEM_HOME" "$BUNDLE_BIN"

USER seluser
