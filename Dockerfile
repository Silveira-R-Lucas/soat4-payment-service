FROM ruby:3.2.2
RUN apt-get update -qq && apt-get install -y nodejs build-essential
WORKDIR /app
COPY Gemfile* ./
RUN bundle install
COPY . .
EXPOSE 3001
CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0", "-p", "3001"]
RUN chown -R 1000:1000 /app
USER 1000