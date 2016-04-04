Rails.application.routes.draw do
  #########################################################
  ##########       Requirements & Concerns       ##########
  #########################################################
  require 'constraints/short_dispatcher'
  concern :modules do
    scope module: 'messages' do
      resources :messages
    end
    scope module: 'contacts' do
      resources :contacts, only: [:index]
      constraints(id: /\d+/) do
        resources :contacts, only: [:create], as: 'contacts_create'
        resources :contacts, except: [:index, :create] do
          resources :emails, only: [:new,:edit,:create,:update,:destroy]
          resources :telephones, only: [:new,:edit,:create,:update,:destroy]
          resources :addresses, only: [:new,:edit,:create,:update,:destroy]
          get 'address-books', to: 'contacts#address_books'
        end
      end
      constraints(id: /(?!address-books$)[0-9a-z\-\_]+/i) do
        resources :address_books, path: 'contacts', only: [:show,:edit,:update]
        resources :address_books, path: 'contacts/address-books', except: [:show,:edit,:update]
      end
      scope '/contacts/:address_book_id', as: 'address_book' do
        resources :contacts, path: ''
      end # ????
    end
    scope module: 'calendar' do
      resources :events, path: '/calendars', only: [:index]
      constraints(id: /\d+/) do
        resources :events, only: [:create], as: 'events_create'
        resources :events, path: '/calendars/events', except: [:index,:create] do
          get 'calendars', to: 'events#calendars'
          resources :attendees
        end
      end
      constraints(id: /(?!calendars$)[0-9a-z\-\_]+/i) do
        resources :calendars, only: [:show,:edit,:update]
        resources :calendars, path: 'calendars/calendars', except: [:show,:edit,:update]
      end
      scope '/calendars/:calendar_id', as: 'calendar' do
        resources :events, path: ''
      end
    end
    scope module: 'time' do
      resources :timers, path: '/time', only: [:index]
      constraints(id: /\d+/) do
        resources :timers, only: [:create], as: 'timers_create'
        resources :timers, path: '/time/timers', except: [:index,:create] do
          get 'time-sheets', to: 'timers#time_sheets'
          resources :assignees
          resources :intervals
        end
      end
      constraints(id: /(?!time-sheets$)[0-9a-z\-\_]+/i) do
        resources :time_sheets, path: '/time', only: [:show,:edit,:update]
        resources :time_sheets, path: 'time/time-sheets', except: [:show,:edit,:update]
      end
      scope '/time/:time_sheet_id', as: 'time_sheet' do
        resources :timers, path: ''
      end
    end
    scope module: 'inventory' do
      resources :items, path: '/inventory', only: [:index]
      constraints(id: /\d+/) do
        resources :items, only: [:create], as: 'items_create'
        resources :items, path: '/inventory/items', except: [:index,:create] do
          get 'containers', to: 'items#containers'
          patch 'amend', to: 'items#consume'
          patch 'purchase', to: 'items#purchase'
          patch 'sell', to: 'items#sell'
        end
      end
      constraints(id: /(?!containers$)[0-9a-z\-\_]+/i) do
        resources :containers, path: '/inventory', only: [:show,:edit,:update]
        resources :containers, path: 'inventory/containers', except: [:show,:edit,:update]
      end
      scope '/inventory/:container_id', as: 'container' do
        resources :items, path: ''
      end
    end
    scope module: 'finances' do
      get '/finances', to: 'finances#index', as: 'finances'
      resources :wallets, path: '/finances/wallets' do
        resources :receipts
        resources :expenses
        #resources :payments
      end
      # resources :ledgers, path: '/finances/ledgers'
      resources :receivables, path: '/finances/receivables' do
        resources :payments
      end
      resources :debts, path: '/finances/debts' do
        resources :payments
      end
    end
  end

  concern :has_modules do
    resources :memberships, path: 'members' do
      member do
        patch 'accept'
        patch 'reject'
      end
    end
    concerns :modules
    resources :projects do
      scope module: 'projects' do
        resources :memberships, path: 'members'
        scope module: 'messages' do
          resources :messages
        end
        scope module: 'calendar' do
          resources :events, path: '/calendars', only: [:index, :create]
          resources :events, path: '/calendars/events', except: [:index,:create] do
            get 'calendars', to: 'events#calendars'
            resources :attendees
          end
        end
        scope module: 'time' do
          resources :timers, path: '/time', only: [:index, :create]
          resources :timers, path: '/time/timers', except: [:index,:create] do
            get 'time-sheets', to: 'timers#time_sheets'
            resources :assignees
            resources :intervals
          end
        end
        scope module: 'finances' do
          get '/finances', to: 'finances#index', as: 'finances'
          resources :wallets, path: '/finances/wallets', only: [:create, :destroy]
          resources :payments, path: '/finances/payments'
          resources :receipts, path: '/finances/receipts'
          resources :expenses, path: '/finances/expenses'
          resources :receivables, path: '/finances/receivables' do
            resources :payments
          end
          resources :debts, path: '/finances/debts' do
            resources :payments
          end
        end

      end
    end
  end
  ###############  Requirements & Concerns  ###############
  #########################################################

  ### ROUTES ->

  devise_for :users, controllers: { registrations: "users/registrations", sessions: "users/sessions", invitations: "users/invitations" }

  scope module: 'site' do
    get '/terms-of-service', to: "home#terms_of_service"
    get '/privacy-policy', to: "home#privacy_policy"
    get '/feedback', to: "home#feedback"
    post '/feedback', to: "feedback#create"
  end
  
  scope module: 'app' do
    get '/contexts', to: 'contexts#index'

    resources :users, only: [:show,:edit,:update]

    resources :organizations, only: [:new]

    resources :groups do
      concerns :has_modules
    end

    resources :businesses, only: [:show,:new,:create]

    scope module: 'contacts' do
      constraints(id: /\d+/) do
        resources :contacts
      end
      constraints(id: /(?!address-books$)[0-9a-z\-\_]+/i) do
        resources :address_books, path: 'contacts', only: [:show,:edit]
        resources :address_books, path: 'contacts/address-books', except: [:show,:edit]
      end
      scope '/contacts/:address_book_id', as: 'address_book' do
        resources :contacts, path: ''
      end
    end
    scope module: 'calendar' do
      constraints(id: /\d+/) do
        resources :events, path: 'calendars'
      end
      constraints(id: /(?!calendars$)[0-9a-z\-\_]+/i) do
        resources :calendars, path: 'calendars', only: [:show,:edit]
        resources :calendars, path: 'calendars/calendars', except: [:show,:edit]
      end
      scope '/calendars/:calendar_id', as: 'calendar' do
        resources :events, path: ''
      end
    end
    scope module: 'time' do
      constraints(id: /\d+/) do
        resources :timers, path: 'time'
      end
      constraints(id: /(?!time-sheets$)[0-9a-z\-\_]+/i) do
        resources :time_sheets, path: 'time', only: [:show,:edit]
        resources :time_sheets, path: 'time/time-sheets', except: [:show,:edit]
      end
      scope '/time/:time_sheet_id', as: 'time_sheet' do
        resources :timers, path: ''
      end
    end
    scope module: 'inventory' do
      scope '/inventory' do
        get 'charts/stock_history'
      end
      constraints(id: /\d+/) do
        resources :items, path: 'inventory'
      end
      constraints(id: /(?!containers$)[0-9a-z\-\_]+/i) do
        resources :containers, path: 'inventory', only: [:show,:edit]
        resources :containers, path: 'inventory/containers', except: [:show,:edit]
      end
      scope '/inventory/:container_id', as: 'container' do
        resources :items, path: ''
      end
    end
    scope '/finances', module: 'finances' do
      get 'charts/wallet_balance'
      get 'charts/ledger_balance'
      get 'charts/resource_balance'
      get '/', to: 'finances#index', as: 'finances'
      resources :wallets
      resources :ledgers
    end
    resources :projects

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
        concerns :has_modules   
      end

    end

    scope '/:business_id', as: 'business' do
      get '/edit', to: 'businesses#edit', as: 'edit'
      patch '/edit', to: 'businesses#update', as: 'update'
      delete '/edit', to: 'businesses#destroy', as: 'destroy'
      resources :ownerships, path: 'owners' do
        member do
          patch 'accept'
          patch 'reject'
        end
      end
    end

    scope '/:resource_id', as: 'resource' do
      concerns :has_modules
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


