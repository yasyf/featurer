class CreateFeatureBranches < ActiveRecord::Migration
  def change
    create_table :feature_branches do |t|
      t.string :name
      t.integer :pr
      t.string :sha
      t.references :repo, index: true

      t.timestamps null: false
    end
  end
end
