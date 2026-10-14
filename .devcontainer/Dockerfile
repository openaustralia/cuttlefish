# Dev-only image. It matches production: Ubuntu 20.04 (focal) with the Ruby in .ruby-version, built from source as
# RVM does there. buildpack-deps is the base the official Ruby images use, so it brings the same development libraries
# for building gems.
FROM buildpack-deps:focal

ARG RUBY_VERSION=3.0.6
RUN git clone --depth 1 https://github.com/rbenv/ruby-build.git /tmp/ruby-build \
    && /tmp/ruby-build/bin/ruby-build "$RUBY_VERSION" /usr/local \
    && rm -rf /tmp/ruby-build

# UTF-8 like production, and gems in /usr/local/bundle, as the official Ruby images set them
ENV LANG=C.UTF-8 GEM_HOME=/usr/local/bundle BUNDLE_APP_CONFIG=/usr/local/bundle BUNDLE_SILENCE_ROOT_WARNING=1
ENV PATH=/usr/local/bundle/bin:$PATH
RUN mkdir -p /usr/local/bundle && chmod 1777 /usr/local/bundle

# A JavaScript runtime for the asset pipeline
RUN apt-get update && apt-get install -y nodejs && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /app
WORKDIR /app

# Run everything as a non-root "deploy" user
RUN groupadd --gid 1000 deploy \
    && useradd --uid 1000 --gid 1000 -m deploy

USER deploy

COPY --chown=deploy:deploy  Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 20 --retry 5

CMD ["/bin/sh", "-c", "rm -f tmp/pids/server.pid && bundle exec rails server -b 0.0.0.0"]
