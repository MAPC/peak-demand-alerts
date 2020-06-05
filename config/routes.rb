# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
    resources :configurations
    resources :forecasts
    resources :reports

    root to: 'configurations#index'
  end

  root to: 'welcome#index'

  resources :forecasts
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
