module ApplicationHelper
  def has_role?(role)
    user_signed_in? && current_user.has_role?(role)
  end

  def has_any_role?(*roles)
    user_signed_in? && current_user.has_any_role?(*roles)
  end

  def impersonating?
    session[:impersonator_id].present?
  end

  def navbar_classes
    return 'bg-warning navbar-light' if impersonating?
    return 'bg-primary navbar-dark' if Rails.env.development?
    'bg-dark navbar-dark'
  end
end
