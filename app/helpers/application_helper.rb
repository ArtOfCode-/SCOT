module ApplicationHelper
  def has_any_role?(*roles)
    user_signed_in? && current_user.has_any_role?(*roles)
  end
end
