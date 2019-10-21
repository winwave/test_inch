Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :persons, only: %i[index show create update destroy]
      resources :buildings, only: %i[index show create update destroy]
    end
  end
end
