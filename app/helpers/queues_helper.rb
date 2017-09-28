module QueuesHelper
  def display_diff_for(property)
    request = @request
    suggested_edit = @suggested_edit
    diff = raw("<span class=\"text-info\"> => #{sanitize(suggested_edit.new_values[property.to_s].to_s)}</span>")
    sanitize(request[property].to_s) + (suggested_edit.new_values[property.to_s].nil? ? '' : diff)
  end
end
