module Erp::Pictures
  class PictureCategory < ApplicationRecord
		mount_uploader :image_url, Erp::Pictures::PictureCategoryImageUploader
    include Erp::CustomOrder
    belongs_to :creator, class_name: "Erp::User"
    validates :name, :presence => true
    
    belongs_to :parent, class_name: "Erp::Pictures::PictureCategory", optional: true
    has_many :children, -> { order(custom_order: :asc) }, class_name: "Erp::Pictures::PictureCategory", foreign_key: "parent_id"
    
    has_many :pictures, dependent: :destroy
    accepts_nested_attributes_for :pictures, :reject_if => lambda { |a| a[:image_url].blank? && a[:image_url_cache].blank? }, :allow_destroy => true
    
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
    
    def self.get_active
			self.where(archived: false).order("custom_order ASC")
		end
    
    def self.get_main_category
			self.get_active.where(level: 1)
		end
    
    def self.filter(query, params)
      params = params.to_unsafe_hash
      and_conds = []

      # show archived items condition - default: false
			show_archived = false

			#filters
			if params["filters"].present?
				params["filters"].each do |ft|
					or_conds = []
					ft[1].each do |cond|
						# in case filter is show archived
						if cond[1]["name"] == 'show_archived'
							# show archived items
							show_archived = true
						else
							if cond[1]["value"] == 'nil'
								or_conds << "#{cond[1]["name"]} IS NULL"
							else
								or_conds << "#{cond[1]["name"]} = '#{cond[1]["value"]}'"
							end
						end
					end
					and_conds << '('+or_conds.join(' OR ')+')' if !or_conds.empty?
				end
			end
			
			#keywords
      if params["keywords"].present?
        params["keywords"].each do |kw|
          or_conds = []
          kw[1].each do |cond|
            or_conds << "LOWER(#{cond[1]["name"]}) LIKE '%#{cond[1]["value"].downcase.strip}%'"
          end
          and_conds << '('+or_conds.join(' OR ')+')'
        end
      end
      # join with users table for search creator
      query = query.joins(:creator)

      # join with parent menu for search menu
      query = query.joins("LEFT JOIN erp_pictures_picture_categories parents_erp_pictures_picture_categories ON parents_erp_pictures_picture_categories.id = erp_pictures_picture_categories.parent_id")

      # showing archived items if show_archived is not true
			query = query.where(archived: false) if show_archived == false

      query = query.where(and_conds.join(' AND ')) if !and_conds.empty?

      return query
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
    
    def picture_category_name
			return self.name
		end
    
    # display name
    def parent_name
			parent.present? ? parent.name : ''
		end
    
    def limit_pictures
			self.pictures.order("created_at asc").limit(4)
		end
    
  end
end
