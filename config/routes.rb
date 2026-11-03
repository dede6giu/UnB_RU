Rails.application.routes.draw do
  get "admin_sessions/new", to: "admin_sessions#new"
  post "admin_sessions", to: "admin_sessions#create"
  get "operator_sessions/new", to: "operator_sessions#new"
  post "operator_sessions", to: "operator_sessions#create"
  get "student_sessions/new", to: "student_sessions#new"
  post "student_sessions", to: "student_sessions#create"
  get "access_points/new", to: "access_points#new"
  post "access_points", to: "access_points#create"
  get "student_portal/new", to: "student_portal#new"

  # scope /admin/<whatever>
  scope "/admin" do
    resources :restaurants
    resources :turnstiles
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
