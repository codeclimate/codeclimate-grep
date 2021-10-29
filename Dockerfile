FROM ruby:2.4-alpine
LABEL maintainer="Code Climate <hello@codeclimate.com>"

WORKDIR /usr/src/app

RUN adduser -u 9000 -D app

RUN apk --no-cache add grep

COPY Gemfile* ./

RUN bundle install --quiet --no-cache --without=test && \
  chown -R app:app /usr/local/bundle && \
  rm -fr ~/.gem ~/.bundle ~/.wh..gem && \
  gem cleanup

COPY . ./

RUN chown -R app:app . && \
  ln engine.json /

USER app
VOLUME /code
WORKDIR /code

CMD ["/usr/src/app/bin/codeclimate-grep"]
