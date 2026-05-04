class CreateRsvps < ActiveRecord::Migration[8.1]
  def change
    create_table :rsvps do |t|
      t.references :post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false

      t.timestamps
    end

    add_index :rsvps, [ :post_id, :user_id ], unique: true
  end
end
