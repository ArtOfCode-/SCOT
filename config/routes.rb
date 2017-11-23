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

    scope 'notifications' do
      root to: 'notifications#index', as: :notifications
      get 'new', to: 'notifications#new', as: :new_notification
      post 'new', to: 'notifications#create', as: :create_notification
      get ':id', to: 'notifications#show', as: :notification
      delete ':id', to: 'notifications#destroy', as: :destroy_notification
      post ':id/read', to: 'notifications#read', as: :read_notification
      post ':id/expire', to: 'notifications#expire', as: :expire_notification
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
      get 'review', to: 'broadcast/items#review', as: :review_broadcast_items
      get ':id/edit', to: 'broadcast/items#edit', as: :edit_broadcast_item
      patch ':id/edit', to: 'broadcast/items#update', as: :update_broadcast_item
      get ':id/added', to: 'broadcast/items#added', as: :added_broadcast_item
      post ':id/deprecate', to: 'broadcast/items#deprecate_item', as: :deprecate_broadcast_item
      get ':id/review', to: 'broadcast/items#item_review', as: :review_broadcast_item
      patch ':id/review', to: 'broadcast/items#submit_review', as: :submit_item_review
    end

    scope 'municipalities' do
      get 'updates', to: 'broadcast/municipalities#last_updates', as: :municipality_updates
    end

    get 'setup', to: 'broadcast/items#setup_generation', as: :broadcast_script_setup
    get 'generate', to: 'broadcast/items#generate_script', as: :broadcast_script
    get 'scripts', to: 'broadcast/items#scripts', as: :broadcast_scripts
    get 'scripts/:file', to: 'broadcast/items#view_script', as: :view_broadcast_script
  end

  scope '/translations' do
    root to: 'translations#index', as: :translations
    get 'mine', to: 'translations#my_requests', as: :my_translation_requests
    get 'mine/assigned', to: 'translations#my_assigns', as: :my_assigned_translations
    get 'new', to: 'translations#new', as: :new_translation
    post 'new', to: 'translations#create', as: :create_translation
    get 'dedupe/data', to: 'translations#dedupe_remote_data', as: :dedupe_translation_remote
    get ':id', to: 'translations#show', as: :translation
    get ':id/final', to: 'translations#final', as: :final_translation
    get ':id/edit', to: 'translations#edit', as: :edit_translation
    patch ':id/edit', to: 'translations#update', as: :update_translation
    post ':id/status', to: 'translations#update_status', as: :update_translation_status
    get ':id/translate', to: 'translations#translate', as: :translate_translation
    post ':id/translate', to: 'translations#complete_translation', as: :complete_translation
    get ':id/dedupe', to: 'translations#deduplicate', as: :deduplicate_translation
    post ':id/dedupe', to: 'translations#submit_dedupe', as: :submit_dedupe_translation
    get ':id/notes', to: 'translations#notes', as: :translation_notes
    post ':id/notes', to: 'translations#submit_notes', as: :submit_translation_notes
  end

  scope '/dev' do
    get 'impersonate/stop', to: 'developers#change_back', as: :change_user_back
    post 'impersonate/stop', to: 'developers#verify_elevation', as: :stop_impersonating
    get 'impersonate/:id', to: 'developers#change_users', as: :change_user
  end

  scope '/cad' do
    scope 'notes' do
      post ':rid/new', to: 'dispatch/case_notes#create', as: :cad_create_case_note
      get ':rid', to: 'dispatch/case_notes#get', as: :cad_get_case_notes
      post ':id/edit', to: 'dispatch/case_notes#update', as: :cad_update_case_note
      delete ':id', to: 'dispatch/case_notes#destroy', as: :cad_destroy_case_note
    end

    scope 'crews' do
      root to: 'dispatch/rescue_crews#index', as: :cad_rescue_crews
    end

    scope ':disaster_id' do
      root to: 'dispatch/requests#index', as: :cad_requests
      get 'dashboard', to: 'dispatch/requests#cad', as: :cad_dashboard
      get 'new', to: 'dispatch/requests#new', as: :cad_new_request
      post 'new', to: 'dispatch/requests#create', as: :cad_create_request
      get ':id', to: 'dispatch/requests#show', as: :cad_request
      get ':id/edit', to: 'dispatch/requests#edit', as: :cad_edit_request
      patch ':id/edit', to: 'dispatch/requests#update', as: :cad_update_request
      delete ':id', to: 'dispatch/requests#destroy', as: :cad_destroy_request
      post ':id/crew', to: 'dispatch/requests#assign_crew', as: :cad_assign_crew
      post ':id/close', to: 'dispatch/requests#close', as: :cad_close_request
    end
  end
end
