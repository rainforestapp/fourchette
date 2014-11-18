class Fourchette::PullRequest
  include SuckerPunch::Job

  def perform(params)
    return if qa_skip?(params)

    callbacks = Fourchette::Callbacks.new(params)
    fork = Fourchette::Fork.new(params)

    callbacks.before_all

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

    callbacks.after_all
  end

  private

  def qa_skip?(params)
    pr_title = params['pull_request']['title']
    pr_title.downcase.include?('[qa skip]')
  end
end
