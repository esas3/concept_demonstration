class UsersController < ApplicationController
  before_filter :find_user, :only => [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.xml
  def index
    @users = User.find :all

    respond_to do |wants|
      wants.html # index.html.erb
      wants.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @documents = Document.find(:all, :from => "/users/#{@user.id}/documents")
    respond_to do |wants|
      wants.html # show.html.erb
      wants.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  # def new
  #   @user = User.new
  # 
  #   respond_to do |wants|
  #     wants.html # new.html.erb
  #     wants.xml  { render :xml => @user }
  #   end
  # end

  # GET /users/1/edit
  # def edit
  # end

  # POST /users
  # POST /users.xml
  # def create
  #   @user = User.new(params[:user])
  # 
  #   respond_to do |wants|
  #     if @user.save
  #       flash[:notice] = 'User was successfully created.'
  #       wants.html { redirect_to(@user) }
  #       wants.xml  { render :xml => @user, :status => :created, :location => @user }
  #     else
  #       wants.html { render :action => "new" }
  #       wants.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end

  # PUT /users/1
  # PUT /users/1.xml
  # def update
  #   respond_to do |wants|
  #     if @user.update_attributes(params[:user])
  #       flash[:notice] = 'User was successfully updated.'
  #       wants.html { redirect_to(@user) }
  #       wants.xml  { head :ok }
  #     else
  #       wants.html { render :action => "edit" }
  #       wants.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /users/1
  # DELETE /users/1.xml
  # def destroy
  #   @user.destroy
  # 
  #   respond_to do |wants|
  #     wants.html { redirect_to(users_url) }
  #     wants.xml  { head :ok }
  #   end
  # end

  private
    def find_user
      @user = User.find(params[:id])
    end

end
