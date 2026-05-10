class CreateCommunities < ActiveRecord::Migration[8.1]
  def change
    create_table :communities do |t|
      t.string :name, null: false
      t.text :description
      t.bigint :creator_id, null: false

      t.timestamps
    end
    add_index :communities, :name, unique: true
    add_index :communities, :creator_id
    add_foreign_key :communities, :users, column: :creator_id
  end
end
