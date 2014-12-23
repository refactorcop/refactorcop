#!/bin/sh

bin/rake db:create
bin/rake db:migrate

if [ "$RAILS_ENV" = "production" ]; then
  bin/rake assets:precompile
fi

bundle exec foreman start
