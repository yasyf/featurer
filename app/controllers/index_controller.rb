class IndexController < ApplicationController
  def index
    feature_branch = FeatureBranch.from_request request
    if !feature_branch.docker_image?
      feature_branch.build
    elsif !feature_branch.docker_container?
      feature_branch.launch
    else
      host = request.host.split('.')[3..-1].join('.')
      redirect_to "http://#{host}:#{feature_branch.port}" and return
    end
    @op = feature_branch.docker_operation
  end
end
