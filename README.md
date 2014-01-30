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

- `ENV['github_project'] = "jipiboily/fourchette"`
- `ENV['github_personal_token'] = 'a token here...'` # You can create one here: https://github.com/settings/applications
- `ENV['heroku_api_key'] = 'API key here'`
- `ENV['heroku_source_name_app'] = 'the name of the app to fork from'`


## It needs some love...

What needs to be improved?

- commenting the PR with URL for testing
- post deploy steps, for migration and such
- it is not serious until there are specs for it, so add specs for that once we have a solid direction
- Code Climate enabled
- Travis CI enabled
- make it a gem
- security improvements (we should not accept hooks from anyone else than GitHub)
- oAuth instead of Token
- multi project would be great