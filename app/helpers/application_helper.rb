module ApplicationHelper

  def alert_class_for_type(type)
    if %w(alert error).include?(type)
      'alert-danger'
    elsif %w(alert error).include?(type)
      'alert-success'
    elsif 'notice' == type
      'alert-info'
    elsif 'timedout' == type
      nil
    else
      "alert-#{type}"
    end
  end

end
