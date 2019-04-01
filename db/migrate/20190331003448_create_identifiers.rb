class CreateIdentifiers < ActiveRecord::Migration[5.1]
  def change
    create_table :identifiers do |t|
      t.string :name, null: false, index: true, unique: true

      t.timestamps
    end
  end
end
