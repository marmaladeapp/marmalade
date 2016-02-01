Rails.application.routes.draw do
  require 'constraints/short_dispatcher'
  devise_for :users, controllers: { registrations: "users/registrations", sessions: "users/sessions", invitations: "users/invitations" }

  scope module: 'app' do
    resources :users, only: [:index, :show]
    authenticated :user do
      root :to => "dashboard#index", as: :authenticated
    end
  end

  scope module: 'site' do
    get '/terms-of-service', to: "home#terms_of_service"
    get '/privacy-policy', to: "home#privacy_policy"
    match '/:id', to: Constraints::ShortDispatcher.new(self), :via => 'get', :as => 'vanity'
    #scope '/:resource_id', as: 'resource' do
    #  match '/edit', to: Constraints::EditDispatcher.new(self), :via => 'get'
    #end
    root "home#index"
  end
end


