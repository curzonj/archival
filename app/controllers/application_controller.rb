# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :require_password

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

  private
  def require_password
    authenticate_or_request_with_http_basic do |id, password| 
      id == ENV['HTTP_LOGIN'] && password == ENV['HTTP_PASSWORD']
    end
  end
end
