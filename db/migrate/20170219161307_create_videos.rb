class CreateVideos < ActiveRecord::Migration[5.0]
  def change
    create_table :videos do |t|
      t.string :title
      t.text :thumbnail
      t.text :description
      t.text :link
      t.boolean :published, default: false
      t.string :duration
      t.string :host
      t.integer :pv, default: 0

      t.timestamps
    end
  end
end
