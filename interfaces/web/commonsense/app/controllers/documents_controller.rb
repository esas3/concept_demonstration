class DocumentsController < ApplicationController
  before_filter :find_document, :only => [:show, :condensed, :edit, :update, :destroy]

  # GET /documents
  # GET /documents.xml
  def index
    @documents = Document.find :all

    respond_to do |wants|
      wants.html # index.html.erb
      wants.xml  { render :xml => @documents }
    end
  end
  
  def correlate
    case params[:commit].downcase
    when "relate"
      if params[:document_ids].count != 2
        flash[:error] = "Select two documents to relate"
      else
        uri = Document.site.to_s + "/document_relations"
        begin
          resp = RestClient.post(uri,
            :one => params[:document_ids].first, 
            :two => params[:document_ids].last
          )
          flash[:notice] = "Successfully created relation"
        rescue
          flash[:error] = "Could not create relation: " + $!
        end
      end
    when "tag"
      if params[:tag_name].blank?
        flash[:error] = "Specify tag to relate to!"
      else
        tag = Tag.find(:first, :params => { :name => params[:tag_name] })
        unless tag
          RestClient.post(Document.site.to_s + "/tags", :name => params[:tag_name]) 
          tag = Tag.find(:first, :params => { :name => params[:tag_name] })
        end
        begin
          uri = Document.site.to_s + "/tag_document_relations"
          params[:document_ids].each do |docid|
            RestClient.post(uri, :tag => tag.id, :document => docid)
          end
          flash[:notice] = "Successfully tagged documents."
        rescue
          flash[:error] = "Could not tag one or more documents. " + $!
        end
      end
    end
    redirect_to request.referer || root_path
  end

  # GET /documents/1
  # GET /documents/1.xml
  def show
    if params[:show_temporally_related] == "true"
      @temporally_related = Document.find(:all, 
        :from => "/documents/#{@document.id}/temporally_related"
      )
    end
    respond_to do |wants|
      wants.html # show.html.erb
      wants.xml  { render :xml => @document }
      wants.json  { render :json => @document }
    end
  end
  
  def condensed
    render :layout => false
  end

  # GET /documents/new
  # GET /documents/new.xml
  def new
    @document = Document.new

    respond_to do |wants|
      wants.html # new.html.erb
      wants.xml  { render :xml => @document }
    end
  end

  # GET /documents/1/edit
  def edit
  end

  # POST /documents
  # POST /documents.xml
  def create
    @document = Document.new(params[:document])

    respond_to do |wants|
      if @document.save
        flash[:notice] = 'Document was successfully created.'
        wants.html { redirect_to(@document) }
        wants.xml  { render :xml => @document, :status => :created, :location => @document }
      else
        wants.html { render :action => "new" }
        wants.xml  { render :xml => @document.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /documents/1
  # PUT /documents/1.xml
  def update
    respond_to do |wants|
      if @document.update_attributes(params[:document])
        flash[:notice] = 'Document was successfully updated.'
        wants.html { redirect_to(@document) }
        wants.xml  { head :ok }
      else
        wants.html { render :action => "edit" }
        wants.xml  { render :xml => @document.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /documents/1
  # DELETE /documents/1.xml
  def destroy
    @document.destroy

    respond_to do |wants|
      wants.html { redirect_to(documents_url) }
      wants.xml  { head :ok }
    end
  end

  private
    def find_document
      @document = Document.find(params[:id], :params => {:include_doc => true})
    end

end
