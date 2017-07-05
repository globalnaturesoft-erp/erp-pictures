module Erp
  module Pictures
    module Backend
      class PictureCategoriesController < Erp::Backend::BackendController
        before_action :set_picture_category, only: [:move_up, :move_down, :archive, :unarchive, :edit, :update, :destroy]
        before_action :set_picture_categories, only: [:delete_all, :archive_all, :unarchive_all]

        # GET /picture_categories
        def index
        end

        # POST /picture_categories/list
        def list
          @picture_categories = PictureCategory.search(params).paginate(:page => params[:page], :per_page => 20)

          render layout: nil
        end

        # GET /picture_categories/new
        def new
          @picture_category = PictureCategory.new
          48.times do
            @picture_category.pictures.build
          end
        end

        # GET /picture_categories/1/edit
        def edit
          (48 - @picture_category.pictures.count).times do
            @picture_category.pictures.build
          end
        end

        # POST /picture_categories
        def create
          @picture_category = PictureCategory.new(picture_category_params)
          @picture_category.creator = current_user
          48.times do
            @picture_category.pictures.build
          end
          if @picture_category.save
            if request.xhr?
              render json: {
                status: 'success',
                text: @picture_category.name,
                value: @picture_category.id
              }
            else
              redirect_to erp_pictures.edit_backend_picture_category_path(@picture_category), notice: t('.success')
            end
          else
            render :new
          end
        end

        # PATCH/PUT /picture_categories/1
        def update
          if @picture_category.update(picture_category_params)
            if request.xhr?
              render json: {
                status: 'success',
                text: @picture_category.name,
                value: @picture_category.id
              }
            else
              redirect_to erp_pictures.edit_backend_picture_category_path(@picture_category), notice: t('.success')
            end
          else
            render :edit
          end
        end

        # DELETE /picture_categories/1
        def destroy
          @picture_category.destroy

          respond_to do |format|
            format.html { redirect_to erp_pictures.backend_picture_categories_path, notice: t('.success') }
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # ARCHIVE /picture_categories/archive?id=1
        def archive
          @picture_category.archive
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # UNARCHIVE /picture_categories/archive?id=1
        def unarchive
          @picture_category.unarchive
          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # DELETE ALL /picture_categories/delete_all?ids=1,2,3
        def delete_all
          @picture_categories.destroy_all

          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # ARCHIVE ALL /picture_categories/archive_all?ids=1,2,3
        def archive_all
          @picture_categories.archive_all

          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # UNARCHIVE ALL /picture_categories/unarchive_all?ids=1,2,3
        def unarchive_all
          @picture_categories.unarchive_all

          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # DATASELECT
        def dataselect
          respond_to do |format|
            format.json {
              render json: PictureCategory.dataselect(params[:keyword].strip)
            }
          end
        end

        # Move up /picture_categories/up?id=1
        def move_up
          @picture_category.move_up

          respond_to do |format|
          format.json {
            render json: {
            #'message': t('.success'),
            #'type': 'success'
            }
          }
          end
        end

        # Move down /picture_categories/up?id=1
        def move_down
          @picture_category.move_down

          respond_to do |format|
          format.json {
            render json: {
            #'message': t('.success'),
            #'type': 'success'
            }
          }
          end
        end

        private
          # Use callbacks to share common setup or constraints between actions.
          def set_picture_category
            @picture_category = PictureCategory.find(params[:id])
          end

          def set_picture_categories
            @picture_categories = PictureCategory.where(id: params[:ids])
          end

          # Only allow a trusted parameter "white list" through.
          def picture_category_params
            params.fetch(:picture_category, {}).permit(:image_url, :name, :description, :parent_id,
                                                       :pictures_attributes => [:id, :image_url, :image_url_cache, :picture_category_id, :_destroy ])
          end
      end
    end
  end
end