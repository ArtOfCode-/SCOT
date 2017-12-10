module RescueRequestsHelper
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
end
