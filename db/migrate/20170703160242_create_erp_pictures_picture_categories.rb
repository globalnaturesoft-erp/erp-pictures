class CreateErpPicturesPictureCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :erp_pictures_picture_categories do |t|
      t.string :name
      t.text :description
      t.integer :parent_id
      t.integer :custom_order
      t.boolean :archived, default: false
      t.references :user, index: true, references: :erp_users

      t.timestamps
    end
  end
end
