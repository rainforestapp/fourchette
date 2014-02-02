class Fourchette::PullRequest
  include SuckerPunch::Job

  def perform params
    callbacks = Fourchette::Callbacks.new(params)
    @params = params

    callbacks.before

    case action
    when 'synchronize' # new push against the PR
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

  def action
    @params['action']
  end

  def fork
    @fork ||= Fourchette::Fork.new(@params)
  end
end