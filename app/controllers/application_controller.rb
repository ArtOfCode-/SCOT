class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  (Role.all.map { |x| x.name.to_sym } + Role.global_defaults).uniq.each do |r|
    define_method "require_#{r}" do
      unless current_user&.has_role?(r)
        @role_name = r.to_s.humanize.titleize
        render :missing_permission, status: 403
      end
    end
  end

  def require_any(*args)
    unless current_user&.has_any_role? *args
      @role_name = args.map { |r| r.to_s.humanize.titleize }.to_sentence(two_words_connector: ' or ', last_word_connector: ', or ')
      render :missing_permission, status: 403
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit :sign_up, keys: [:username]
  end
end
