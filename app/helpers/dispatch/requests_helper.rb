module Dispatch::RequestsHelper
  def status_el(status, wrap = 'p')
    cls = %w[text-danger text-warning text-success text-info][status.index]
    icon = %w[exclamation-triangle exclamation-circle check info-circle][status.index]
    raw("<#{wrap} class='#{cls}'>Status: <i class='fa fa-#{icon}'></i> #{status.name}</#{wrap}>")
  end

  def priority_el(priority, wrap = 'p')
    cls = %w[text-danger text-warning text-success][priority.index]
    icon = %w[exclamation-triangle exclamation-circle check info-circle][priority.index]
    raw("<#{wrap} class='#{cls}'>Priority: <i class='fa fa-#{icon}'></i> #{priority.name}</#{wrap}>")
  end
end
