class CreateUuidsIdentifiersJoinTable < ActiveRecord::Migration[5.1]
  def change
    create_join_table :uuids, :identifiers do |t|
      t.references :identifier, foreign_key: {on_delete: :cascade}
      t.references :uuid, foreign_key: {on_delete: :cascade}
    end
    add_index :identifiers_uuids, [:identifier_id, :uuid_id], unique: true
  end
end
