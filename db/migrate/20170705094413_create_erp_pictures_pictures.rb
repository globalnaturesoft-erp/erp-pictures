class CreateErpPicturesPictures < ActiveRecord::Migration[5.0]
  def change
    create_table :erp_pictures_pictures do |t|
      t.string :image_url
      t.integer :custom_order
      t.references :picture_category, index: true, references: :erp_pictures_picture_categories
      
      t.timestamps
    end
  end
end
