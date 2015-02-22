class Repo < ActiveRecord::Base
  has_many :feature_branches
  after_save :create_hook

  store :secrets, coder: JSON

  def full_name
    "#{user}/#{name}"
  end

  def client
    @client ||= Octokit::Client.new(:access_token => Rails.application.secrets.gh_token)
  end

  private

  def create_hook
    config = {url: "http://#{ENV['HOOK_HOST']}/webhook", :content_type => 'json'}
    options = {events: ['pull_request', 'delete'], active: true}
    client.create_hook full_name, 'docker', config, options
  end
end
