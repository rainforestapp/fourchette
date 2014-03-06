# Fourchette

[![Code Climate](https://codeclimate.com/github/jipiboily/fourchette.png)](https://codeclimate.com/github/jipiboily/fourchette)
[![Build Status](https://travis-ci.org/jipiboily/fourchette.png?branch=master)](https://travis-ci.org/jipiboily/fourchette)

**IMPORTANT: this is a work in progress, use at your own risk.**

Fourchette is your new best friend for having isolated testing environements. It will help you test your GitHub PRs against a fork of one your Heroku apps. You will have one Heroku app per PR now. Isn't that amazing? It will make testing way easier and you won't have the (maybe) broken code from other PRs on staging but only the code that requires testing.

*IMPORTANT: Please note that forking your Heroku app means it will copy the same addon plans and that you will pay for multiple apps and their addons. Watch out!*

## Flow

- a PR is created against your GitHub project
- Fourchette receives an event via GitHub Hooks
-- it [forks](https://devcenter.heroku.com/articles/fork-app) an environement making it available to you
-- any new commit against that PR will update the code
- closing the PR will delete the forked app
- re-opening the PR will re-create a fork

## Diagram

Seriously? You need a diagram for that? Nope. Not going to do this. PRs accepted...I guess.

# Features
- single project
- configuration is made via environement variables
- async processing
- it works, but that's about it for now

## Installation

Those steps could be made way easier, but this is a really minimal implementation.

1. clone this repo
2. push to Heroku
3. configure the right environement variables (see [#configuration](#configuration))
4. Enable your Fourchette instance

### Configuration

- `export FOURCHETTE_GITHUB_PROJECT="jipiboily/fourchette"`
- `export FOURCHETTE_GITHUB_USERNAME="jipiboily"`
- `export FOURCHETTE_GITHUB_PERSONAL_TOKEN='a token here...'` # You can create one here: https://github.com/settings/applications
- `export FOURCHETTE_HEROKU_USERNAME='me@domain'`
- `export FOURCHETTE_HEROKU_API_KEY='API key here'`
- `export FOURCHETTE_HEROKU_APP_TO_FORK='the name of the app to fork from'`
- `export FOURCHETTE_APP_URL="http://fourchette-app.herokuapp.com"`
- `export FOURCHETTE_HEROKU_APP_PREFIX="fourchette"` # This is basically to namespace your forks. In that example, they would be named "fourchette-pr-1234" where "1234" is the PR number. Beware, the name can't be more than 30 characters total! It will be changed to be lowercase only, so you should probably just use lowercase characters anyways.

### Enable your Fourchette instance

run `bundle exec rake fourchette:enable`

### Enable, disable, update or delete the hook

`bundle exec rake -T` will tell you the rake tasks available. There are tasks to enable, disable or delete the GitHub hook to your Fourchette instance. There is also one to update the hook. That last one is mostly for development, if your local tunnel URl changed and you want to update the hook's URL.

### Before & after steps

You need to run steps before and/or after the creation of your new Heroku app? Let's say you want to run mirgations after deploying new code. There is a simple (and primitive) way of doing it. It might not be perfect but can work until there is a cleaner and more flexible way of doing so, if required.

Basically, you just want to modify the `before` or `after` methods of `Fourchette::Callbacks` (`lib/fourchette/callbacks.rb`) to suit your needs. In those methods, you have access to GitHub's hook data via the `@param` instance variable.

## Rake tasks

```
rake fourchette:console  # Brings up a REPL with the code loaded
rake fourchette:delete   # This deletes the Fourchette hook
rake fourchette:disable  # This disables Fourchette hook
rake fourchette:enable   # This enables Fourchette hook
rake fourchette:update   # This updates the Fourchette hook with the current URL of the app
```

## Async processing note

Fourchette uses [Sucker Punch](https://github.com/brandonhilkert/sucker_punch), "a single-process Ruby asynchronous processing library". No need for redis or extra processes. It also mean it can run for free on Heroku, if this is what you want.

## Contribute

- fork & clone
- `bundle install`
- `foreman start`
- You now have the app running on port 9292

Bonus: if you need a tunnel to your local dev machine to work with GitHub hooks, you might want to look at https://ngrok.com/.

## It needs some love...

What needs to be improved?

- currently, it is assuming everything goes well, very little to no error management. This needs to improved.
- it is not serious until there are specs for it, so add specs for that once we have a solid direction
- add Travis CI
- add Coveralls
- make it a gem
-- imrpove how to deal with callbacks as part of making this a gem
- security improvements (we should not accept hooks from anyone else than GitHub)
- oAuth instead of GitHub token?
- multi project would be great
