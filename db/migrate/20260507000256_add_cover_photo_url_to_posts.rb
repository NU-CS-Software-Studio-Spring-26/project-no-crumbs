class AddCoverPhotoUrlToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :cover_photo_url, :string
  end
end
