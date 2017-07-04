Erp::Pictures::Engine.routes.draw do
    scope "(:locale)", locale: /en|vi/ do
		namespace :backend, module: "backend", path: "backend/pictures" do
			resources :menus do
				collection do
					post 'list'
					get 'dataselect'
					delete 'delete_all'
					put 'archive'
					put 'unarchive'
					put 'archive_all'
					put 'unarchive_all'
					put 'move_up'
					put 'move_down'
				end
			end
        end
	end
end