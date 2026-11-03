Rails.application.routes.draw do
  resource :admin_session, only: [ :new, :create ]
  resource :operator_session, only: [ :new, :create ]
  resource :student_session, only: [ :new, :create ]
  resource :access_point, only: [ :new, :create ]
  resource :student_portal, only: [ :show ], controller: "student_portal"

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
