class CreatePictograms < ActiveRecord::Migration[5.2]
  def change
    create_table :pictograms do |t|
      t.string :title
      t.string :image_url
      t.string :label
    end
  end
end
