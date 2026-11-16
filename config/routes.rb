Rails.application.routes.draw do
  post "access_control/check", to: "access_control#check", as: :access_control_check

  resource :access_point, only: [ :new, :create, :show, :destroy ] do
    get :confirm_disconnect
  end

  scope "/admin" do
    get "/login", to: "admin_sessions#new"
    post "/login", to: "admin_sessions#create", as: :admin_session
    resources :restaurants
    resources :turnstiles
  end

  scope "/operator" do
    get "/login", to: "operator_sessions#new"
  end

  scope "/student" do
    get "/login", to: "student_sessions#new"
    post "/login", to: "student_sessions#create", as: :student_session

    get "/signup", to: "student_sessions#signup"
    post "/newacc", to: "student_sessions#newacc", as: :student_session_newacc

    get "/portal", to: "student_portal#show", as: :student_portal

    get "/recharge", to: "recharges#new", as: :new_recharge
    post "/recharge", to: "recharges#create", as: :recharge

    get "/statement", to: "statements#show", as: :statement
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # get "up" => "rails/health#show", as: :rails_health_check

  root to: redirect("/student/login")
end
