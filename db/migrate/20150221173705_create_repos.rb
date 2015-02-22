class CreateRepos < ActiveRecord::Migration
  def change
    create_table :repos do |t|
      t.string :user
      t.string :name
      t.string :dockerfile

      t.timestamps null: false
    end
  end
end
