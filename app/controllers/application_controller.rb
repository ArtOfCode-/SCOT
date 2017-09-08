class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  protected

  (Role.all.map { |x| x.name.to_sym } + Role.global_defaults).uniq.each do |r|
    define_method "require_#{r}" do
      unless current_user&.has_role?(r)
        @role_name = r
        render :missing_permission, status: 403
      end
    end
  end
end
