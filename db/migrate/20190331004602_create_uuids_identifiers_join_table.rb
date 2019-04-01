class CreateUuidsIdentifiersJoinTable < ActiveRecord::Migration[5.1]
  def change
    create_join_table :uuids, :identifiers do |t|
      t.references :identifier, foreign_key: true
      t.references :uuid, foreign_key: true
    end
    add_index :identifiers_uuids, [:identifier_id, :uuid_id], unique: true
  end
end
