class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.bigint :recipient_id, null: false
      t.bigint :actor_id, null: false
      t.string :notifiable_type, null: false
      t.bigint :notifiable_id, null: false
      t.string :action, null: false
      t.datetime :read_at

      t.timestamps
    end

    add_index :notifications, [ :recipient_id, :read_at ]
    add_index :notifications, [ :notifiable_type, :notifiable_id ]
    add_foreign_key :notifications, :users, column: :recipient_id
    add_foreign_key :notifications, :users, column: :actor_id
  end
end
