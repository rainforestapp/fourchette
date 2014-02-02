class Fourchette::PullRequest
  include SuckerPunch::Job

  def perform params
    @params = params

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
  end

  def action
    @params['action']
  end

  def fork
    @fork ||= Fourchette::Fork.new(@params)
  end
end