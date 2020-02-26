FROM ruby:2.6.0

ENV LANG C.UTF-8
EXPOSE 4000
WORKDIR "/opt"
RUN ["gem", "install", "jekyll"]

CMD ["jekyll", "serve", "--host", "0.0.0.0", "--port", "4000"]
