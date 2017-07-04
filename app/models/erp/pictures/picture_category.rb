module Erp::Pictures
  class PictureCategory < ApplicationRecord
    include Erp::CustomOrder
    belongs_to :user, class_name: "Erp::User"
    validates :name, :presence => true
    belongs_to :parent, class_name: "Erp::Pictures::PictureCategory", optional: true
    has_many :children, -> { order(custom_order: :asc) }, class_name: "Erp::Pictures::PictureCategory", foreign_key: "parent_id"
    after_save :update_level
    
    # init custom order
    def init_custom_order
			self.update_column(:custom_order, self.class.maximum("custom_order").to_i + 1)
		end

    # update level
    def update_level
			level = 1
			parent = self.parent
			while parent.present?
				level += 1
				parent = parent.parent
			end

			self.update_column(:level, level)
		end
    
    def self.search(params)
      query = self.all
      query = self.filter(query, params)

      # order
      if params[:sort_by].present?
        order = params[:sort_by]
        order += " #{params[:sort_direction]}" if params[:sort_direction].present?

        query = query.order(order)
      end

      return query
    end

    # data for dataselect ajax
    def self.dataselect(keyword='')
      query = self.all

      if keyword.present?
        keyword = keyword.strip.downcase
        query = query.where('LOWER(name) LIKE ?', "%#{keyword}%")
      end

      query = query.limit(8).map{|picture_category| {value: picture_category.id, text: (picture_category.parent_name.empty? ? '' : "#{picture_category.parent_name} / ") + picture_category.name} }
    end

    def archive
			update_columns(archived: true)
		end

		def unarchive
			update_columns(archived: false)
		end

    def self.archive_all
			update_all(archived: true)
		end

    def self.unarchive_all
			update_all(archived: false)
		end
    
    # display name
    def parent_name
			parent.present? ? parent.name : ''
		end
    
  end
end
