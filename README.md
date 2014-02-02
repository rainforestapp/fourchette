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

## Configuration

- `export FOURCHETTE_GITHUB_PROJECT="jipiboily/fourchette"`
- `export FOURCHETTE_GITHUB_USERNAME="jipiboily"`
- `export FOURCHETTE_GITHUB_PERSONAL_TOKEN='a token here...'` # You can create one here: https://github.com/settings/applications
- `export FOURCHETTE_HEROKU_USERNAME='me@domain'`
- `export FOURCHETTE_HEROKU_API_KEY='API key here'`
- `export FOURCHETTE_HEROKU_APP_TO_FORK='the name of the app to fork from'`
- `export FOURCHETTE_APP_URL="http://fourchette-app.herokuapp.com"`
- `export FOURCHETTE_HEROKU_APP_PREFIX="fourchette"` # This is basically to namespace your forks. They will be named "fourchette-PR-1234" where "1234" is the PR number. Beware, the name can't be more than 30 characters total! It will be changed to be lowercase only, so you should probably just use lowercase characters anyways.

## Contribute

- fork & clone
- `bundle install`
- `foreman start -f Procfile.dev`
- You now have the app running on port 9292

Bonus: if you need a tunnel to your local dev machine to work with GitHub hooks, you might want to look at https://ngrok.com/.

## It needs some love...

What needs to be improved?

- post deploy steps, for migration and such
- it is not serious until there are specs for it, so add specs for that once we have a solid direction
- Code Climate enabled
- Travis CI enabled
- make it a gem
- security improvements (we should not accept hooks from anyone else than GitHub)
- oAuth instead of Token
- multi project would be great