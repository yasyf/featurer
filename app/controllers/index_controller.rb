class IndexController < ApplicationController
  def index
    feature_branch = FeatureBranch.from_request request
    host = request.host.split('.')[3..-1].join('.')
    process_branch feature_branch, host
  end

  def branch
    feature_branch = FeatureBranch.from_params params
    process_branch feature_branch, request.host
    render 'index/index'
  end

  private

  def process_branch(feature_branch, host)
    if !feature_branch.docker_image?
      feature_branch.build_and_launch
    elsif !feature_branch.docker_container?
      feature_branch.launch
    else
      @link = "http://#{host}:#{feature_branch.port}"
    end
    @fb = feature_branch
    @op = feature_branch.docker_operation
  end
end
