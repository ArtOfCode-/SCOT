module Dispatch::RequestsHelper
  def status_el(status, wrap = 'p')
    cls = "text-#{status.marker_type}"
    icon = status.icon
    raw("<#{wrap} class='#{cls}' title='#{status.description}' data-toggle='tooltip'>Status: <i class='fa fa-#{icon}'></i> #{status.name}</#{wrap}>")
  end

  def priority_el(priority, wrap = 'p')
    cls = %w[text-danger text-warning text-success][priority.index]
    icon = %w[exclamation-triangle exclamation-circle check info-circle][priority.index]
    raw("<#{wrap} class='#{cls}' title='#{priority.description}' data-toggle='tooltip'>"\
        "Priority: <i class='fa fa-#{icon}'></i> #{priority.name}</#{wrap}>")
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
