module Erp::Pictures
  class Picture < ApplicationRecord
    mount_uploader :image_url, Erp::Pictures::PictureCategoryImageUploader
    belongs_to :picture_category, optional: true
    
    default_scope { order(id: :asc) }
  end
end
