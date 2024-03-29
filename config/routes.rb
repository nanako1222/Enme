Rails.application.routes.draw do
  get 'favorites/create'
  get 'favorites/destroy'
  devise_for :customers, controllers: {
    registrations: "customer/registrations",
    sessions: 'customer/sessions'
  }

  devise_for :restaurants, controllers: {
    registrations: "restaurant/registrations",
    sessions: 'restaurant/sessions'
  }

  devise_for :admin, skip: [:registrations, :passwords], controllers: {
    sessions: "admin/sessions"
  }

  root :to  => 'customer/homes#top'
  get '/about' => 'customer/homes#about'
  resources :areas, only: :index

  # resources :areas do
  #   collection do
  #     get :customer_farm_area
  #   end
  # end

  namespace :admin do
    resources :customers, only: [:show, :index, :edit, :update]
    get '/areas/index' => "areas#index"
    get '/areas/:id' => "areas#show",as: "areas"
    resources :allergies, only: [:create, :index, :edit, :update, :destroy]
    resources :restaurants, only: [:show, :edit, :update]
    get '/' => 'homes#top'
  end

  namespace :restaurant do
    get '/' => 'homes#top', as: 'homes'
    # get "information/:id/edit", to: "homes#edit", as: "information_edit"
    get "information/edit", to: "homes#edit", as: "information_edit"
    patch "/information" => "homes#update"
    get "/confirm" => "homes#confirm"
    get '/about' => 'homes#about'
    patch '/out' => 'homes#out'
    resources :restaurants, only: [:update, :edit] do
      resources :menus, only: [:index, :show, :new, :create, :edit, :update, :destroy]
    end
  end

  scope module: :customer do

    # resources :restaurant_menus, only: [:index, :show]
    # get "/restaurants/search" => "restaurants#search"
    resources :restaurants, only: [:create,:index, :show] do
      collection do
        get "search"
        get "simple_search"
      end
      resources :menus, only: [:index, :show]
      resource :favorites, only: [:create, :destroy]
    end

    # resources :customers do
    #   resource :favorites, only: [:create, :destroy]
    # end
    # resources :customers, only: %i[new create]
    # resources :favorite_restaurants do
    #   resources :comments, only: %i[create update destroy], shallow: true
    #   collection do
    #     get :favorites
    #   end
    # end
    # resources :favorites, only: %i[create destroy]

    patch "/customers/information" => "customers#update"
    get "/customers/information/edit" => "customers#edit",as: "customers_information_edit"
    get "/my_page" => "customers#my_page"
    get "/customers/confirm" => "customers#confirm",as: "customers_confirm"
    patch '/customers/out' => 'customers#out'
    get "/customers/favorite/index" => "favorites#index"
  end
end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
