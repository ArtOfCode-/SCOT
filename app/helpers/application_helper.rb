module ApplicationHelper
  def has_role?(role)
    user_signed_in? && current_user.has_role?(role)
  end

  def has_any_role?(*roles)
    user_signed_in? && current_user.has_any_role?(*roles)
  end
end
