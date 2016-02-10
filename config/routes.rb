Rails.application.routes.draw do
  require 'constraints/short_dispatcher'
  devise_for :users, controllers: { registrations: "users/registrations", sessions: "users/sessions", invitations: "users/invitations" }

  scope module: 'app' do
    resources :users, only: [:show,:edit,:update]

    scope '/:user_id', as: 'user' do
      get '/profile', to: 'users#profile'
      get '/password', to: 'users#password', as: 'pass'
      patch '/password', to: 'users#update_password', as: 'update_pass'
      get '/subscription', to: 'users#subscription'
      patch '/subscribe', to: 'users#subscribe'
      patch '/update_subscription', to: 'users#update_subscription'
      get '/payment', to: 'users#payment'
      patch '/payment', to: 'users#pay_subscription'
      get '/billing', to: 'users#billing'
      patch '/billing', to: 'users#update_payment'
    end

    match '/:id', to: Constraints::ShortDispatcher.new(self), :via => 'get', :as => 'vanity'
    authenticated :user do
      root :to => "dashboard#index", as: :authenticated
    end
  end

  scope module: 'site' do
    get '/terms-of-service', to: "home#terms_of_service"
    get '/privacy-policy', to: "home#privacy_policy"
    #match '/:id', to: Constraints::ShortDispatcher.new(self), :via => 'get', :as => 'vanity'
    #scope '/:resource_id', as: 'resource' do
    #  match '/edit', to: Constraints::EditDispatcher.new(self), :via => 'get'
    #end
    root "home#index"
  end
end


