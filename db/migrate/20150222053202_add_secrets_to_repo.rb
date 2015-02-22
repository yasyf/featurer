class AddSecretsToRepo < ActiveRecord::Migration
  def change
    add_column :repos, :secrets, :text
  end
end
