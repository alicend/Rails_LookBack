Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "health_check", to: "health_check#index"

      # 認証関連ルート
      post "signup/request", to: "auth#send_sign_up_email"
      # post '/invite/request', to: 'auth#send_invite_email'
      post "signup", to: "auth#create"
      # post '/invite/signup', to: 'auth#create'
      post 'login', to: 'auth#login'
      get 'login/guest', to: 'auth#guest_login'
      get 'logout', to: 'auth#logout'

      resources :tasks do
        collection do
          get 'task-board', to: 'tasks#task_board_index'
          get 'look-back', to: 'tasks#look_back_index'
          post '', to: 'tasks#create'
        end

        member do
          put '', to: 'tasks#update'
          put 'to-completed', to: 'tasks#update_to_completed'
          delete '', to: 'tasks#destroy'
        end
      end

      resources :categories do
        collection do
          get '', to: 'categories#index'
          post '', to: 'categories#create'
        end

        member do
          put '', to: 'categories#update'
          delete '', to: 'categories#destroy'
        end
      end

      resources :users do
        collection do
          get '', to: 'users#index'

          get 'me', to: 'users#current_user'
          post 'me/email/request', to: 'users#send_update_email_email'
          # put 'me/email', to: 'users#update_current_user_email'
          put 'me/name', to: 'users#update_current_user_name'
          put 'me/password', to: 'users#update_current_user_password'
          # put 'me/user-group', to: 'users#update_current_user_group'
          # delete 'me', to: 'users#delete_current_user'

          put 'password', to: 'users#reset_password'
          post 'password/request', to: 'users#send_email_reset_password'
        end
      end

      resources :user_groups , path: 'user-groups' do
        member do
          put '', to: 'user_groups#update'
          delete '', to: 'user_groups#destroy'
        end
      end

    end
  end
end
