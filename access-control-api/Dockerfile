FROM ruby:3.2.4-alpine3.18

RUN apk add --update --no-cache build-base git vips libpq-dev sqlite-libs tzdata less

ARG UID=1000
ARG GID=1000
RUN addgroup -g $GID -S appuser && \
    adduser -u $UID -S -G appuser appuser

ENV APP_PATH=/usr/src
WORKDIR $APP_PATH

COPY Gemfile* $APP_PATH/
RUN bundle install -j4

COPY . .

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]