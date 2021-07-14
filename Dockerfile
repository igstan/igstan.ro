FROM ruby:2.6.0

ENV LANG C.UTF-8
EXPOSE 4000
WORKDIR "/opt"

RUN ["gem", "install", "redcarpet", "-v", "3.5.1"]
RUN ["gem", "install", "pygments.rb", "-v", "2.2.0"]
RUN ["gem", "install", "kramdown-parser-gfm", "-v", "1.1.0"]
RUN ["gem", "install", "jekyll", "-v", "3.9"]

CMD ["jekyll", "serve", "--drafts", "--host", "0.0.0.0", "--port", "4000"]
