# frozen_string_literal: true

Rails.application.routes.draw do
  root 'home#index'
  get :search, to: 'home#search'
end
