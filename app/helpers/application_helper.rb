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

  def maps_javascript(callback)
    javascript_include_tag("https://maps.googleapis.com/maps/api/js?key=#{Settings.maps_api_key}&libraries=places&callback=#{callback}",
                           'data-turbolinks-eval': false) +
        stylesheet_link_tag('shims/maps_font')
  end

  def marker_paths
    markers = %w[success info warning danger]
    raw(markers.map { |a| [a, asset_url("marker_#{a}.png")] }
            .map { |p| "<a class='maps-marker-ref' data-name='#{p[0]}' href='#{p[1]}'></a>" }
            .join)
  end
end
