class Repo < ActiveRecord::Base
  has_many :feature_branches

  store :secrets, coder: JSON

  def full_name
    "#{user}/#{name}"
  end
end
