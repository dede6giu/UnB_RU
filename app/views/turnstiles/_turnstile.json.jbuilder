json.extract! turnstile, :id, :name, :operation, :created_at, :updated_at
json.url turnstile_url(turnstile, format: :json)
