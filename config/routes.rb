Rails.application.routes.draw do
  devise_for :users

  root to: 'disasters#index', as: :root

  scope '/disasters' do
    root to: 'disasters#index', as: :disasters
  end
end
