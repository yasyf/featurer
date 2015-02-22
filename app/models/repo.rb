class Repo < ActiveRecord::Base
  has_many :feature_branches, dependent: :destroy
  after_save :create_hook
  before_destroy :delete_hook

  store :secrets, coder: JSON

  def full_name
    "#{user}/#{name}"
  end

  def client
    @client ||= Octokit::Client.new(:access_token => ENV['GH_TOKEN'] || Rails.application.secrets.gh_token)
  end

  def hook
    ENV['HOOK_HOST'] && client.hooks(full_name).find { |hook| hook[:config][:url].include? ENV['HOOK_HOST'] }
  end

  private

  def create_hook
    if ENV['HOOK_HOST'] and !hook.present?
      config = {url: "http://#{ENV['HOOK_HOST']}/webhook", :content_type => 'json'}
      options = {events: ['pull_request', 'delete'], active: true}
      client.create_hook full_name, 'web', config, options
    end
  end

  def delete_hook
    if hook.present?
      client.remove_hook full_name, hook[:id]
    end
  end
end
