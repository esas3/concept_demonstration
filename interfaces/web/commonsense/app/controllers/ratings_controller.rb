class RatingsController < ApplicationController
  before_filter :find_rating, :only => [:show, :edit, :update, :destroy]

  # GET /ratings
  # GET /ratings.xml
  def index
    @ratings = Rating.find(:all)

    respond_to do |wants|
      wants.html # index.html.erb
      wants.xml  { render :xml => @ratings }
    end
  end

  # GET /ratings/1
  # GET /ratings/1.xml
  def show
    respond_to do |wants|
      wants.html # show.html.erb
      wants.xml  { render :xml => @rating }
    end
  end

  # GET /ratings/new
  # GET /ratings/new.xml
  def new
    @rating = Rating.new

    respond_to do |wants|
      wants.html # new.html.erb
      wants.xml  { render :xml => @rating }
    end
  end

  # GET /ratings/1/edit
  def edit
  end

  # POST /ratings
  # POST /ratings.xml
  def create
    @rating = Rating.new(params[:rating])

    # respond_to do |wants|
      if @rating.save
        flash[:notice] = 'Rating was successfully created.'
        # wants.html { redirect_to(@rating) }
        # wants.xml  { render :xml => @rating, :status => :created, :location => @rating }
      else
        # wants.html { render :action => "new" }
        # wants.xml  { render :xml => @rating.errors, :status => :unprocessable_entity }
      end
    # end
    redirect_to request.referer || root_path
  end

  # PUT /ratings/1
  # PUT /ratings/1.xml
  def update
    respond_to do |wants|
      if @rating.update_attributes(params[:rating])
        flash[:notice] = 'Rating was successfully updated.'
        wants.html { redirect_to(@rating) }
        wants.xml  { head :ok }
      else
        wants.html { render :action => "edit" }
        wants.xml  { render :xml => @rating.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /ratings/1
  # DELETE /ratings/1.xml
  def destroy
    @rating.destroy

    respond_to do |wants|
      wants.html { redirect_to(ratings_url) }
      wants.xml  { head :ok }
    end
  end

  private
    def find_rating
      @rating = Rating.find(params[:id])
    end

end
