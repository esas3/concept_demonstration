# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  before_filter :get_stats

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
  
  def get_stats
    @stats ||= JSON.parse(
      RestClient.get((Document.site + "stats").to_s).body
    )["stats"]
  end
end
