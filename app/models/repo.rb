class Repo < ActiveRecord::Base
  has_many :feature_branches

  def full_name
    "#{user}/#{name}"
  end
end
