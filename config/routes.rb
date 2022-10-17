Rails.application.routes.draw do
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
    resources :allergies, only: [:create, :index, :edit, :update]
    resources :restaurants, only: [:show, :edit, :update]
    get '/' => 'homes#top'
  end
  namespace :restaurant do
    resources :menus, only: [:create, :index, :show, :new, :edit, :update, :destroy]
    get '/' => 'homes#top'
    get "information/edit" => "homes#edit"
    patch "/information" => "homes#update"
    get "/confirm" => "homes#confirm"
    patch '/out' => 'homes#out'
    resources :restaurants, only: [:update, :edit]
  end
  scope module: :customer do
  end

  resources :restaurant_menus, only: [:show, :index]
  get "/restaurants/serch" => "restaurants#serch"
  resources :restaurants, only: [:create, :index, :show]
  patch "/customers/information" => "customers#update"
  get "/customers/information/edit" => "customers#edit"
  get "/customers/my_page" => "customers#show"
  get "/customers/confirm" => "customers#confirm"
  patch '/customers/out' => 'customers#out'
  get "/customers/favorite/index" => "customers#index"

end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
