#!/bin/sh

# NOTE: This the entry point of our docker image

bin/rake db:create
bin/rake db:migrate

if [ "$RAILS_ENV" = "production" ]; then
  bin/rake assets:precompile
fi

bundle exec foreman start
