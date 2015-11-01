FROM ruby:2.2.3

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev
RUN mkdir /refactorcop
WORKDIR /refactorcop
ADD Gemfile /refactorcop/Gemfile
ADD Gemfile.lock /refactorcop/Gemfile.lock
RUN mkdir ~/.ssh
RUN echo "github.com,192.30.252.131 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==" > ~/.ssh/known_hosts

RUN bundle install
ADD . /refactorcop

ENV REDIS_URL redis://redis:6379
ENV PORT 3000

VOLUME [ "/refactorcop" ]
EXPOSE 3000
ENTRYPOINT ./script/start.sh
