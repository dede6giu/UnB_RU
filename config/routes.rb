Rails.application.routes.draw do
  post "access_control/check", to: "access_control#check", as: :access_control_check

  resource :admin_session, only: [ :new, :create ]
  resource :operator_session, only: [ :new, :create ]
  resource :student_session, only: [ :new, :create ]
  resource :access_point, only: [ :new, :create, :show, :destroy ] do
    get :confirm_disconnect
  end
  resource :student_portal, only: [ :show ], controller: "student_portal"
  resource :recharge, only: [ :new, :create ]
  resource :statement, only: [ :show ]

  # scope /admin/<whatever>
  scope "/admin" do
    resources :restaurants
    resources :turnstiles
  end

  get "student_session/signup" => "student_sessions#signup"
  post "student_session/newacc" => "student_sessions#newacc"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root to: redirect("/student_session/new")
end
