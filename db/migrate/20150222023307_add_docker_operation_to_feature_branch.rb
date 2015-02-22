class AddDockerOperationToFeatureBranch < ActiveRecord::Migration
  def change
    change_table :feature_branches do |t|
      t.references :docker_operation
    end
  end
end
