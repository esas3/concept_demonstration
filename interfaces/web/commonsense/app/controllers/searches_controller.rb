class SearchesController < ApplicationController
  def index
    unless params[:q].blank?
      @documents = begin
        Document.find(:all, :from => "/documents/search/attr_content:#{CGI.escape params[:q]}")
      rescue
        flash[:error] = "Searched by name. " + $!
        Document.find(:all, :from => :by_name, :params => { :name => params[:q]} )
      end
    end
  end

end