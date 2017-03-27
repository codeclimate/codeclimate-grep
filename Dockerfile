FROM ruby:2.4-alpine

RUN apk --update add grep

WORKDIR /usr/src/app

COPY Gemfile* ./
RUN gem install -g

RUN adduser -u 9000 -D app
RUN chown -R app:app /usr/src/app
USER app

COPY . ./

VOLUME /code
WORKDIR /code

CMD ["/usr/src/app/bin/codeclimate-grep"]
