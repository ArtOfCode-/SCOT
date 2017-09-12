module AccessLogger
  extend ActiveSupport::Concern

  included do
    before_action :log_access

    private

    def log_access
      if log_actions.present? && log_actions.include?(action_name.to_sym)
        if current_user.present?
          action = "#{controller_name}##{action_name}"
          AccessLog.create(user: current_user, action: action, url: request.original_url, resource: @loggable)
        else
          flash[:danger] = 'You must sign in first.'
          redirect_to new_user_session_path
        end
      end
    end
  end
end