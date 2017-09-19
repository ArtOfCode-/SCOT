module AccessLogger
  extend ActiveSupport::Concern

  included do
    before_action :log_access

    private

    def log_access
      if log_actions.present? && log_actions.include?(action_name.to_sym)
        action = "#{controller_name}##{action_name}"
        if current_user.present?
          AccessLog.create(user: current_user, action: action, url: request.original_url, resource: @loggable)
        else
          Rails.logger.warn 'Creating AccessLog with no user because nobody is signed in!'
          AccessLog.create(action: action, url: request.original_url, resource: @loggable)
        end
      end
    end
  end
end