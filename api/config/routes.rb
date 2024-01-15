Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "health_check", to: "health_check#index"

      # 認証関連ルート
      post "signup/request", to: "auth#send_sign_up_email"
      # post '/invite/request', to: 'auth#send_invite_email'
      post "/signup", to: "auth#create"
      # post '/invite/signup', to: 'auth#create'
      post '/login', to: 'auth#login'
      get '/login/guest', to: 'auth#guest_login'
      get '/logout', to: 'auth#logout'



      resources :users do
        collection do
          post 'password', to: 'users#reset_password'
          post 'password/request', to: 'users#send_email_reset_password'
        end
      end

    end
  end
end
