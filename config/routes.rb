Rails.application.routes.draw do
  devise_for :users

  root to: 'disasters#index', as: :root

  scope '/admin' do
    scope '/roles' do
      root to: 'roles#index', as: :admin_roles
      post 'add', to: 'roles#add_role', as: :admin_add_role
      post 'remove', to: 'roles#remove_role', as: :admin_remove_role
      post 'lead', to: 'roles#add_lead', as: :admin_lead_role
    end

    scope 'accesses' do
      get ':resource_type/:resource_id', to: 'access_logs#on_resource', as: :resource_access_logs
    end
  end

  scope '/disasters' do
    root to: 'disasters#index', as: :disasters
    get 'new', to: 'disasters#new', as: :new_disaster
    post 'new', to: 'disasters#create', as: :create_disaster

    get 'requests', to: 'rescue_requests#index', as: :global_requests
    scope ':disaster_id' do
      scope 'requests' do
        root to: 'rescue_requests#disaster_index', as: :disaster_requests
        get 'new', to: 'rescue_requests#new', as: :new_disaster_request
        post 'new', to: 'rescue_requests#create', as: :create_disaster_request
        post 'update', to: 'rescue_requests#update', as: :update_disaster_request
        post ':num/suggest_edit', to: 'rescue_requests#suggest_edit_submit', as: :suggested_edit_submit
        get ':num/edit', to: 'rescue_requests#edit', as: :edit_disaster_request
        get ':num/suggest_edit', to: 'rescue_requests#suggest_edit', as: :suggest_edit_disaster_request
        get ':num', to: 'rescue_requests#show', as: :disaster_request
        get ':num/status', to: 'rescue_requests#triage_status', as: :request_triage_status
        get ':num/auth', to: 'rescue_requests#authorizations', as: :request_authorizations
        get ':num/assignee', to: 'rescue_requests#assignee', as: :change_request_assignee
        post ':num/assignee', to: 'rescue_requests#apply_assignee', as: :apply_request_assignee
        post ':num/status', to: 'rescue_requests#apply_triage_status', as: :request_apply_status
        post ':num/medical_status', to: 'rescue_requests#apply_medical_triage_status', as: :request_apply_medical_status
        post ':num/safe', to: 'rescue_requests#mark_safe', as: :request_rescue_safe
      end
    end
  end

  scope '/requests' do
    scope ':request_id' do
      scope 'notes' do
        get 'new', to: 'case_notes#new', as: :new_case_note
        post 'new', to: 'case_notes#create', as: :create_case_note
        get ':id/edit', to: 'case_notes#edit', as: :edit_case_note
        patch ':id/edit', to: 'case_notes#update', as: :update_case_note
        delete ':id', to: 'case_notes#destroy', as: :destroy_case_note
      end

      scope 'contacts' do
        get 'new', to: 'contact_attempts#new', as: :new_contact_attempt
        post 'new', to: 'contact_attempts#create', as: :create_contact_attempt
        get ':id/edit', to: 'contact_attempts#edit', as: :edit_contact_attempt
        patch ':id/edit', to: 'contact_attempts#update', as: :update_contact_attempt
        delete ':id', to: 'contact_attempts#destroy', as: :destroy_contact_attempt
      end

      scope 'edits' do
        post ':id/approve', to: 'suggested_edits#approve', as: :approve_suggested_edit
        post ':id/reject', to: 'suggested_edits#reject', as: :reject_suggested_edit
      end
    end
  end

  scope '/statuses' do
    scope '/rescue_request' do
      root to: 'request_status#index', as: :request_status_index
      patch ':num/update', to: 'request_status#update', as: :request_status_update
      get ':num/edit', to: 'request_status#edit', as: :request_status_edit
      get 'new', to: 'request_status#new', as: :request_status_new
      post 'create', to: 'request_status#create', as: :request_status_create
    end

    scope '/medical' do
      root to: 'medical_status#index', as: :medical_status_index
      get ':num/edit', to: 'medical_status#edit', as: :medical_status_edit
      patch ':num/update', to: 'medical_status#update', as: :medical_status_update
      get 'new', to: 'medical_status#new', as: :medical_status_new
      post 'create', to: 'medical_status#create', as: :medical_status_create
    end
  end

  scope '/queues' do
    scope 'dedupe' do
      root to: 'queues#dedupe', as: :dedupe_queue
      post 'complete', to: 'queues#dedupe_complete', as: :dedupe_complete
    end
    scope 'spam' do
      root to: 'queues#spam', as: :spam_queue
      post 'complete', to: 'queues#spam_complete', as: :spam_complete
    end
    scope 'suggested_edit' do
      root to: 'queues#suggested_edit', as: :suggested_edit_queue
      post 'complete', to: 'queues#suggested_edit_complete', as: :suggested_edit_complete
    end
    scope 'meta' do
      get 'suggested_edit', to: 'queues#review_suggested_edit_reviews', as: :review_suggested_edit_reviews
      get 'spam', to: 'queues#review_spam_reviews', as: :review_spam_reviews
      get 'dedupe', to: 'queues#review_dedupe_reviews', as: :review_dedupe_reviews
    end
  end

  scope '/api' do
    scope 'requests' do
      get 'geojson', to: 'api#geojson', as: :api_geojson
      get 'csv', to: 'api#csv', as: :api_csv
    end
  end

  scope '/users' do
    scope 'authorizations' do
      post 'new', to: 'user_authorizations#create', as: :create_authorization
      delete ':id', to: 'user_authorizations#destroy', as: :destroy_authorization
    end
  end

  scope '/broadcast' do
    scope 'items' do
      root to: 'broadcast/items#index', as: :broadcast_items
      get 'new', to: 'broadcast/items#new', as: :new_broadcast_item
      post 'new', to: 'broadcast/items#create', as: :create_broadcast_item
      get 'need-translation', to: 'broadcast/items#need_translation', as: :translatable_broadcast_items
      get ':id/edit', to: 'broadcast/items#edit', as: :edit_broadcast_item
      patch ':id/edit', to: 'broadcast/items#update', as: :update_broadcast_item
      get ':id/added', to: 'broadcast/items#added', as: :added_broadcast_item
      get ':id/translate', to: 'broadcast/items#add_translation', as: :translate_broadcast_item
      post ':id/translate', to: 'broadcast/items#submit_translation', as: :submit_broadcast_translation
      post ':id/deprecate', to: 'broadcast/items#deprecate_item', as: :deprecate_broadcast_item
    end

    get 'setup', to: 'broadcast/items#setup_generation', as: :broadcast_script_setup
    get 'generate', to: 'broadcast/items#generate_script', as: :broadcast_script
  end
end
