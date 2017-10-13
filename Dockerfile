FROM ruby:2.4-alpine
LABEL maintainer="Code Climate <hello@codeclimate.com>"

WORKDIR /usr/src/app

RUN adduser -u 9000 -D app

RUN apk --no-cache add grep

COPY Gemfile* ./
RUN bundler install --no-cache --without=test --system && \
  chown -R app:app /usr/local/bundle && \
  rm -r ~/.bundle

COPY . ./

RUN chown -R app:app . && \
  ln engine.json /

USER app
VOLUME /code
WORKDIR /code

CMD ["/usr/src/app/bin/codeclimate-grep"]
