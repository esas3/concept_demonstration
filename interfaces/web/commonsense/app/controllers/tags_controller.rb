class TagsController < ApplicationController
  before_filter :find_tag, :only => [:show, :edit, :update, :destroy]

  # GET /tags
  # GET /tags.xml
  def index
    unless params[:id]
      @tags = Tag.find :all
    else
      @documents = Document.find :all, :from => '/tags/documents', :params => { :id => params[:id] }
    end

    respond_to do |wants|
      wants.html # index.html.erb
      wants.xml  { render :xml => @tags }
      wants.json do
        render :json => @tags.collect do |tag| 
          tag.attributes.merge(
            :children => tag.documents.collect { |d| 
              { :id => d.id, :name => d.name, :children => d.destinations.collect { |dest| 
                { :id  => dest.id, :name => dest.name, :children => [] } 
              }, :data => {} } 
            }
          )
        end
      end
    end
  end

  # GET /tags/1
  # GET /tags/1.xml
  def show
    respond_to do |wants|
      wants.html # show.html.erb
      wants.xml  { render :xml => @tag }
      wants.json do
        render :json => @tag.attributes.merge(
          :children => @tag.documents.collect { |d| {:id => d.id, :name => d.name, :children => d.destinations.collect {|dest| {:id  => dest.id, :name => dest.name, :children => []}}, :data => {} } }
        )
      end
    end
  end

  # GET /tags/new
  # GET /tags/new.xml
  def new
    @tag = Tag.new

    respond_to do |wants|
      wants.html # new.html.erb
      wants.xml  { render :xml => @tag }
    end
  end

  # GET /tags/1/edit
  def edit
  end

  # POST /tags
  # POST /tags.xml
  def create
    @tag = Tag.new(params[:tag])

    respond_to do |wants|
      if @tag.save
        flash[:notice] = 'Tag was successfully created.'
        wants.html { redirect_to(@tag) }
        wants.xml  { render :xml => @tag, :status => :created, :location => @tag }
      else
        wants.html { render :action => "new" }
        wants.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tags/1
  # PUT /tags/1.xml
  def update
    respond_to do |wants|
      if @tag.update_attributes(params[:tag])
        flash[:notice] = 'Tag was successfully updated.'
        wants.html { redirect_to(@tag) }
        wants.xml  { head :ok }
      else
        wants.html { render :action => "edit" }
        wants.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tags/1
  # DELETE /tags/1.xml
  def destroy
    @tag.destroy

    respond_to do |wants|
      wants.html { redirect_to(tags_url) }
      wants.xml  { head :ok }
    end
  end

  private
    def find_tag
      @tag = Tag.find(params[:id])
    end

end
