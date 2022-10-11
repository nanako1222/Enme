Rails.application.routes.draw do
  namespace :admin do
    get 'customers/index'
    get 'customers/show'
    get 'customers/edit'
    get 'customers/update'
  end
  namespace :admin do
    get 'areas/index'
  end
  namespace :admin do
    get 'allergys/index'
    get 'allergys/create'
    get 'allergys/edit'
    get 'allergys/update'
  end
  namespace :admin do
    get 'restaurants/edit'
    get 'restaurants/update'
    get 'restaurants/show'
  end
  namespace :admin do
    get 'homes/top'
  end
  namespace :restaurant do
    get 'menus/index'
    get 'menus/edit'
    get 'menus/update'
    get 'menus/new'
    get 'menus/create'
    get 'menus/show'
    get 'menus/destroy'
  end
  namespace :restaurant do
    get 'homes/top'
    get 'homes/edit'
    get 'homes/update'
  end
  namespace :customer do
    get 'restaurant_menu/index'
    get 'restaurant_menu/show'
  end
  namespace :customer do
    get 'restaurants/show'
    get 'restaurants/index'
    get 'restaurants/create'
  end
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
  root to: 'homes#top'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
