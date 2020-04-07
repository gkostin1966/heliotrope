class CreateModelTreeVertices < ActiveRecord::Migration[5.1]
  def self.up
    create_table :model_tree_vertices do |t|
      t.string :noid, null: false, index: true, unique: true
      t.string :data, null: false, default: '{}'
    end
  end

  def self.down
    drop_table :model_tree_vertices
  end
end
