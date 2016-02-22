Rails.application.routes.draw do
  require 'constraints/short_dispatcher'
  devise_for :users, controllers: { registrations: "users/registrations", sessions: "users/sessions", invitations: "users/invitations" }

  scope module: 'site' do
    get '/terms-of-service', to: "home#terms_of_service"
    get '/privacy-policy', to: "home#privacy_policy"
  end
  
  scope module: 'app' do
    get '/contexts', to: 'contexts#index'

    resources :users, only: [:show,:edit,:update]

    resources :organizations, only: [:new]

    resources :groups do
      resources :memberships, path: 'members'
      scope module: 'contacts' do
        resources :address_books, path: 'contacts'
      end
      scope module: 'calendar' do
        resources :calendars
      end
      scope module: 'time' do
        resources :time_sheets, path: 'time'
      end
      scope '/finances', module: 'finances' do
        get '/', to: 'finances#index', as: 'finances'
        resources :wallets
        resources :ledgers
      end
      scope module: 'projects' do
        resources :projects
      end
    end

    resources :businesses, only: [:show,:new,:create]

    scope module: 'contacts' do
      resources :address_books, path: 'contacts'
    end
    scope module: 'calendar' do
      resources :calendars
    end
    scope module: 'time' do
      resources :time_sheets, path: 'time'
    end
    scope '/finances', module: 'finances' do
      get 'charts/wallet_balance'
      get 'charts/resource_balance'
      get '/', to: 'finances#index', as: 'finances'
      resources :wallets
      resources :ledgers
    end
    scope module: 'projects' do
      resources :projects
    end

    ## The Tricky Part ##
    match '/:id', to: Constraints::ShortDispatcher.new(self), :via => 'get', :as => 'vanity'

    scope '/:user_id', as: 'user' do
      # profile management
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
      # / profile management

      scope '/home', as: 'home' do
        root 'households#show', as: ''
        get '/new', to: 'households#new', as: 'new'
        post '/new', to: 'households#create', as: 'create'
        get '/edit', to: 'households#edit', as: 'edit'
        patch '/edit', to: 'households#update', as: 'update'
        delete '/edit', to: 'households#destroy', as: 'destroy'
        resources :memberships, path: 'members'

        scope module: 'contacts' do
          resources :address_books, path: 'contacts'
        end
        scope module: 'calendar' do
          resources :calendars
        end
        scope module: 'time' do
          resources :time_sheets, path: 'time'
        end
        scope '/finances', module: 'finances' do
          get '/', to: 'finances#index', as: 'finances'
          resources :wallets
          resources :ledgers
        end
        scope module: 'projects' do
          resources :projects
        end
      end

    end

    scope '/:business_id', as: 'business' do
      get '/edit', to: 'businesses#edit', as: 'edit'
      patch '/edit', to: 'businesses#update', as: 'update'
      delete '/edit', to: 'businesses#destroy', as: 'destroy'
      resources :ownerships, path: 'owners'
      resources :memberships, path: 'members'
    end

    scope '/:resource_id', as: 'resource' do
      scope module: 'contacts' do
        resources :address_books, path: 'contacts'
      end
      scope module: 'calendar' do
        resources :calendars
      end
      scope module: 'time' do
        resources :time_sheets, path: 'time'
      end
      scope '/finances', module: 'finances' do
        get '/', to: 'finances#index', as: 'finances'
        resources :wallets
        resources :ledgers
      end
      scope module: 'projects' do
        resources :projects
      end
    end
    #/ the tricky part ##

    authenticated :user do
      root :to => "dashboard#index", as: :authenticated
    end
  end

  scope module: 'site' do
    #match '/:id', to: Constraints::ShortDispatcher.new(self), :via => 'get', :as => 'vanity'
    #scope '/:resource_id', as: 'resource' do
    #  match '/edit', to: Constraints::EditDispatcher.new(self), :via => 'get'
    #end
    root "home#index"
  end
end


