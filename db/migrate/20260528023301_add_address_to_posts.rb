class AddAddressToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :address, :string
  end
end
