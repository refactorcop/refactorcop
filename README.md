# [RefactorCop](http://www.refactorcop.com)

[![Build
Status](https://travis-ci.org/railsrumble/refactorcop.svg?branch=master)](https://travis-ci.org/railsrumble/refactorcop)

Using [RuboCop](https://github.com/bbatsov/rubocop), RefactorCop scans open
source Ruby projects, allowing you to discover code that may benefit from your
contribution.

## Getting started

```
bundle install

# Sets up database and imports Github's trending Ruby projects
rake db:setup

# Start server and sidekiq workers
foreman start
```

# Contributing

1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request

## About

The initial version of this project was built during the [Rails Rumble
2014](http://r14.railsrumble.com/entries/winners) by
[aliekens](https://github.com/aliekens),
[mcls](https://github.com/mcls),
[stelianfirez](https://github.com/stelianfirez) and [zzip](https://github.com/zzip).

## License

RefactorCop is released under the [MIT License](http://www.opensource.org/licenses/MIT).
