<p align="center">
  <a href="https://github.com/rainforestapp/fourchette">
    <img src="http://i.imgur.com/967yX36.png" alt="Fourchette" />
  </a>
  <br />
  <b>Your new best friend for isolated testing environments on Heroku</b>
  <br />
  <a href="https://codeclimate.com/github/rainforestapp/fourchette"><img src="http://img.shields.io/codeclimate/github/rainforestapp/fourchette.svg?style=flat" /></a>
  <a href="https://travis-ci.org/rainforestapp/fourchette"><img src="http://img.shields.io/travis/rainforestapp/fourchette/master.svg?style=flat" /></a>
  <a href='https://coveralls.io/r/rainforestapp/fourchette'><img src='http://img.shields.io/coveralls/rainforestapp/fourchette.svg?style=flat' alt='Coverage Status' /></a>
  <a href="http://badge.fury.io/rb/fourchette"><img src="http://img.shields.io/gem/v/fourchette.svg?style=flat" alt="Gem Version" height="18"></a>
</p>

Fourchette is your new best friend for having isolated testing environments. It will help you test your @GitHub PRs against a fork of one your @Heroku apps. You will have one Heroku app per PR now. Isn't that amazing? It will make testing way easier and you won't have the (maybe) broken code from other PRs on staging but only the code that requires testing.

Fourchette is maintained by @jipiboily! You can see the other [contributors here](https://github.com/rainforestapp/fourchette/graphs/contributors).

**IMPORTANT: Please note that forking your Heroku app means it will copy the same addon plans and that you will pay for multiple apps and their addons. Watch out!**

## Table of content
1. [How does that work exactly?](#how-does-that-work-exactly)
- [Installation](#installation)
  * [Configuration](#configuration)
  * [Enable your Fourchette instance](#enable-your-fourchette-instance)
  * [Enable, disable, update or delete the hook](#enable-disable-update-or-delete-the-hook)
  * [Before & after steps; aka callbacks](#before--after-steps-aka-callbacks)
- [Rake tasks](#rake-tasks)
- [Async processing note](#async-processing-note)
- [Contribute](#contribute)
  - [Logging](#logging)
- [Contributors](#contributors)

## How does that work exactly?

1. A PR is created against your GitHub project
- Fourchette then receives an event via GitHub Hooks:
  - It [forks](https://devcenter.heroku.com/articles/fork-app) an environment making it available to you
  - Any new commit against that PR will update the code
- Closing the PR will delete the forked app
- Re-opening the PR will re-create a fork

We use it a lot at [Rainforest QA](https://www.rainforestqa.com/). If you want to see a sample Fourchette app, here is one for you to look at: https://github.com/rainforestapp/rf-ourchette.

## Installation

1. run `gem install fourchette`
2. run `fourchette new my-app-name`. You can replace "my-app-name" by whatever you want it, this is the name of the directory your Fourchette app will be created in.
3. run `cd my-app-name` (replace app name, again)
4. run `git init && git add . && git commit -m "Initial commit :tada:"`
5. push to Heroku
6. configure the right environment variables (see [#configuration](#configuration))
7. Enable your Fourchette instance

### Configuration

- `export FOURCHETTE_GITHUB_PROJECT="rainforestapp/fourchette"`
- `export FOURCHETTE_GITHUB_USERNAME="rainforestapp"`
- `export FOURCHETTE_GITHUB_PERSONAL_TOKEN='a token here...'` # You can create one here: https://github.com/settings/applications
- `export FOURCHETTE_HEROKU_API_KEY="API key here"`
- `export FOURCHETTE_HEROKU_APP_TO_FORK='the name of the app to fork from'`
- `export FOURCHETTE_APP_URL="http://fourchette-app.herokuapp.com"`
- `export FOURCHETTE_HEROKU_APP_PREFIX="fourchette"` # This is basically to namespace your forks. In that example, they would be named "fourchette-pr-1234" where "1234" is the PR number. Beware, the name can't be more than 30 characters total! It will be changed to be lowercase only, so you should probably just use lowercase characters anyways.

**IMPORTANT**: the GitHub user needs to be an admin of the repo to be able to add, enable or disable the web hook used by Fourchette. You could create it by hand if you prefer.

### Enable your Fourchette instance

run `bundle exec rake fourchette:enable`

### Enable, disable, update or delete the hook

`bundle exec rake -T` will tell you the rake tasks available. There are tasks to enable, disable or delete the GitHub hook to your Fourchette instance. There is also one to update the hook. That last one is mostly for development, if your local tunnel URL changed and you want to update the hook's URL.

### Before & after steps, aka, callbacks

You need to run steps before and/or after the creation of your new Heroku app? Let's say you want to run mirgations after deploying new code. There is a simple (and primitive) way of doing it. It might not be perfect but will work until there is a cleaner and more flexible way of doing so, if required.

Create a file in your project to override the `Fourchette::Callbacks` class and include it after Fourchette.

You just want to override the `before` or `after` methods of `Fourchette::Callbacks` (`lib/fourchette/callbacks.rb`) to suit your needs. In those methods, you have access to GitHub's hook data via the `@param` instance variable.

## Rake tasks

```bash
rake fourchette:console  # Brings up a REPL with the code loaded
rake fourchette:delete   # This deletes the Fourchette hook
rake fourchette:disable  # This disables Fourchette hook
rake fourchette:enable   # This enables Fourchette hook
rake fourchette:update   # This updates the Fourchette hook with the current URL of the app
```

## QA Skip

Adding `[qa skip]` to the title of your pull request will cause Fourchette to ignore the pull request. This is inspired by the `[ci skip]` directive that [various](http://docs.travis-ci.com/user/how-to-skip-a-build/) [ci tools](https://circleci.com/docs/skip-a-build) support.

## Async processing note

Fourchette uses [Sucker Punch](https://github.com/brandonhilkert/sucker_punch), "a single-process Ruby asynchronous processing library". No need for redis or extra processes. It also mean you can run it for free on Heroku, if this is what you want.

## Contribute

- fork & clone
- `bundle install`
- `foreman start`
- You now have the app running on port 9292

Bonus: if you need a tunnel to your local dev machine to work with GitHub hooks, you might want to look at https://ngrok.com/.

### Logging

If you want the maximum output in your GitHub comments, set this environment variable:

```
export DEBUG='true'
```

# Thanks to...

- [@jpsirois](https://github.com/jpsirois/) for the logo!
