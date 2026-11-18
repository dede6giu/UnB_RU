Rails.application.routes.draw do
  post "access_control/check", to: "access_control#check", as: :access_control_check

  get "/menu", to: "menus#show", as: :public_menu

  scope "/admin" do
    get "/login", to: "admin_sessions#new", as: :new_admin_session
    post "/login", to: "admin_sessions#create", as: :admin_session
    resources :restaurants
    resources :turnstiles
  end

  scope "/operator" do
    get "/login", to: "operator_sessions#new", as: :new_operator_session
    post "/login", to: "operator_sessions#create", as: :operator_session

    get "/access/new", to: "access_points#new", as: :new_access_point
    post "/access", to: "access_points#create"
    get "/access", to: "access_points#show", as: :access_point
    delete "/access", to: "access_points#destroy"
    get "/access/confirm_disconnect", to: "access_points#confirm_disconnect", as: :confirm_disconnect_access_point
  end

  scope "/student" do
    get "/login", to: "student_sessions#new", as: :new_student_session
    post "/login", to: "student_sessions#create", as: :student_session

    get "/signup", to: "student_sessions#signup", as: :student_session_signup
    post "/newacc", to: "student_sessions#newacc", as: :student_session_newacc

    get "/portal", to: "student_portal#show", as: :student_portal

    get "/recharge", to: "recharges#new", as: :new_recharge
    post "/recharge", to: "recharges#create", as: :recharge

    get "/statement", to: "statements#show", as: :statement
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # get "up" => "rails/health#show", as: :rails_health_check

  root to: "home#show"
end
