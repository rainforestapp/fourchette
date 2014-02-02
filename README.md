# Fourchette

Fourchette is your new best friend for having isolated testing environements. It will help you test your PRs against a fork of one your Heroku apps. You will have one Heroku app per PR now. Isn't that amazing? It will make testing way easier and you won't have the broken code from other PRs on staging but only the code that requies testing for that context.

*IMPORTANT: Please note that it also means you will pay for multiple apps and their addons. Watch out!*

## Flow

- a PR is created against your project by one dev of your team
- Fourchette receives an event via GitHub Hooks
-- it [forks](https://devcenter.heroku.com/articles/fork-app) an environement making it available to you
-- any new commit against that PR will update the code

## Diagram

Seriously? You need a diagram for that? Nope. Not going to do this. PRs accepted...I guess.

# MVP features
- single project
- configuration is made via environement variables
- it works, but that's about it for now

## Installation

Those steps could be made way easier, but this is a really minimal implementation.

1. clone this repo
2. push to Heroku
3. configure the right environement variables (see [#configuration](#configuration))

### Configuration

- `export FOURCHETTE_GITHUB_PROJECT="jipiboily/fourchette"`
- `export FOURCHETTE_GITHUB_USERNAME="jipiboily"`
- `export FOURCHETTE_GITHUB_PERSONAL_TOKEN='a token here...'` # You can create one here: https://github.com/settings/applications
- `export FOURCHETTE_HEROKU_USERNAME='me@domain'`
- `export FOURCHETTE_HEROKU_API_KEY='API key here'`
- `export FOURCHETTE_HEROKU_APP_TO_FORK='the name of the app to fork from'`
- `export FOURCHETTE_APP_URL="http://fourchette-app.herokuapp.com"`
- `export FOURCHETTE_HEROKU_APP_PREFIX="fourchette"` # This is basically to namespace your forks. In that example, they would be named "fourchette-pr-1234" where "1234" is the PR number. Beware, the name can't be more than 30 characters total! It will be changed to be lowercase only, so you should probably just use lowercase characters anyways.

### Before & after steps

You need to run steps before and/or after the creation of your new Heroku app? Let's say you want to run mirgations after deploying new code. There is a simple (and primitive) way of doing it. It might not be perfect but can work until there is a cleaner and more flexible way of doing so, if required.

Basically, you just want to modify the `before` or `after` methods of `Fourchette::Callbacks` (`lib/fourchette/callbacks.rb`) to suit your needs. In those methods, you have access to GitHub's hook data via the `@param` instance variable.

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

- it is not serious until there are specs for it, so add specs for that once we have a solid direction
- add Code Climate
- add Travis CI
- add Coveralls
- make it a gem
-- imrpove how to deal with callbacks as part of making this a gem
- security improvements (we should not accept hooks from anyone else than GitHub)
- oAuth instead of GitHub token?
- multi project would be great