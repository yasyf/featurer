class CreateDockerOperations < ActiveRecord::Migration
  def change
    create_table :docker_operations do |t|
      t.string :stage
      t.text :output, default: ''
      t.boolean :pending, default: true
      t.boolean :succeeded, default: false

      t.timestamps null: false
    end
  end
end
