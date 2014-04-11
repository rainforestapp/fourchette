class Fourchette::PullRequest
  include SuckerPunch::Job

  def perform params
    callbacks = Fourchette::Callbacks.new(params)
    fork = Fourchette::Fork.new(params)

    callbacks.before

    case params['action']
    when 'synchronize' # new push against the PR (updating code, basically)
      fork.update
    when 'closed'
      fork.delete
    when 'reopened'
      fork.create
    when 'opened'
      fork.create
    end

    callbacks.after
  end
end