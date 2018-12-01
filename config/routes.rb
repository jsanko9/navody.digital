Rails.application.routes.draw do
  get :health, to: 'health#index'

  namespace :admin do
    root to: redirect('admin/journeys#index')

    resources :journeys do
      resources :steps
    end
    resources :tasks
  end

  root to: 'static#index'

  resources :journeys, path: 'zivotne-situacie'
  get '/zivotne-situacie/:id/:step_slug', to: 'journeys#show', as: 'journey_step' # TODO

  resources :faqs, path: 'casto-kladene-otazky'
  get '/:slug', to: 'static#show', as: :static_page
end
