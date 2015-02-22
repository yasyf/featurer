class WebhookController < ApplicationController
  def index
    event = request.header['X-Github-Event']
    if event == 'pull_request'
      feature_branch = FeatureBranch.from_pr params[:pull_request][:repo][:full_name], params[:number]
      if ['opened', 'reopened', 'synchronize'].include? params[:action]
        unless feature_branch.docker_image? && feature_branch.matches_pr?
          feature_branch.build_and_relaunch
        end
      elsif params[:action] == 'closed'
        feature_branch.stop_and_rm
      end
    elsif event == 'delete'
      if params[:ref_type] == 'branch'
        feature_branch = FeatureBranch.from_ref params[:repository][:full_name], params[:ref]
        if feature_branch.docker_image?
          if feature_branch.docker_container?
            feature_branch.stop_and_rm
          else
            feature_branch.rm
          end
        end
      end
    elsif event == 'ping'
      render head: ok and return
    else
      render json: {error: 'invalid action'}, status: 422 and return
    end
  end
end
