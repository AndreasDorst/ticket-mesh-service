FROM ruby:3.2.4-alpine3.18

# установка библиотек для работы приложения (сейчас отсутствуют)
RUN apk add --update --no-cache build-base git vips libpq-dev sqlite-libs tzdata less

ENV APP_PATH=/usr/src
WORKDIR $APP_PATH

# устаналиваем гемы, необходимые приложению
COPY Gemfile* $APP_PATH/
RUN bundle install -j4

# # копируем код приложения
# COPY . .

# сообщаем другим разработчикам и devopsам о том, на каком порту работает наше приложение
EXPOSE 3000

# устанавливаем команду по умолчанию
CMD ["rails", "server", "-b", "0.0.0.0"]
