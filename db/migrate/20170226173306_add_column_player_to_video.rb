class AddColumnPlayerToVideo < ActiveRecord::Migration[5.0]
  def change
    add_column :videos, :player, :text
  end
end
