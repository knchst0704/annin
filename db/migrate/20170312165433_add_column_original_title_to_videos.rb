class AddColumnOriginalTitleToVideos < ActiveRecord::Migration[5.0]
  def change
    add_column :videos, :original_title, :string
  end
end
