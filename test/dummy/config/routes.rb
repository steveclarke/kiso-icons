# frozen_string_literal: true

Rails.application.routes.draw do
  root "icons#index"
  get "icons/show", to: "icons#show"
end
