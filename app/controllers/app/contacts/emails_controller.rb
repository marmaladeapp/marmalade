class App::Contacts::EmailsController < App::AppController

  def new
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      authorize! :show, @resource, :message => ""
      @context = @resource
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      authorize! :show, @resource, :message => ""
      @context = @resource
    end
    @contact = @context.contacts.find(params[:contact_id])
    @email = @contact.emails.new
  end

  def edit
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      authorize! :show, @resource, :message => ""
      @context = @resource
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      authorize! :show, @resource, :message => ""
      @context = @resource
    end
    @contact = @context.contacts.find(params[:contact_id])
    @email = @contact.emails.find(params[:id])
  end

  def create
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      authorize! :show, @resource, :message => ""
      @context = @resource
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      authorize! :show, @resource, :message => ""
      @context = @resource
    end
    @contact = @context.contacts.find(params[:contact_id])
    @email = @contact.emails.new(email_params)
    if @email.save
      if params[:resource_id]
        redirect_to resource_contact_path(@resource,@contact)
      elsif params[:user_id]
        redirect_to user_home_contact_path(@user,@contact)
      elsif params[:group_id]
        redirect_to group_contact_path(@context,@contact)
      end
    else
      render 'new'
    end
  end

  def update
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      authorize! :show, @resource, :message => ""
      @context = @resource
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      authorize! :show, @resource, :message => ""
      @context = @resource
    end
    @contact = @context.contacts.find(params[:contact_id])
    @email = @contact.emails.find(params[:id])
    if @email.update_attributes(email_params)
      if params[:resource_id]
        redirect_to resource_contact_path(@resource,@contact)
      elsif params[:user_id]
        redirect_to user_home_contact_path(@user,@contact)
      elsif params[:group_id]
        redirect_to group_contact_path(@context,@contact)
      end
    else
      render 'edit'
    end
  end

  def destroy
  end

  private

  def email_params
    params.require(:contact_details_email).permit(:address)
  end
end
