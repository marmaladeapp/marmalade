class App::Contacts::AddressesController < App::AppController

  def new
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
    end
    if params[:address_book_id]
      @address_book = @resource.address_books.find(params[:address_book_id])
    end
    @contact = ::Contacts::Contact.find(params[:contact_id])
    @address = @contact.addresses.new
  end

  def edit
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
    end
    if params[:address_book_id]
      @address_book = @resource.address_books.find(params[:address_book_id])
    end
    @contact = ::Contacts::Contact.find(params[:contact_id])
    @address = @contact.addresses.find(params[:id])
  end

  def create
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
    end
    @contact = ::Contacts::Contact.find(params[:contact_id])
    @address = @contact.addresses.new(address_params)
    if @address.save
      redirect_to root_path
    else
      render 'new'
    end
  end

  def update
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
    end
    if params[:address_book_id]
      @address_book = @resource.address_books.find(params[:address_book_id])
    end
    @contact = ::Contacts::Contact.find(params[:contact_id])
    @address = @contact.addresses.find(params[:id])
    if @address.update_attributes(address_params)
      redirect_to root_path
    else
      render 'new'
    end
  end

  def destroy
  end

  private

  def address_params
    params.require(:contact_details_address).permit(:line_1,:line_2,:city,:state,:zip,:country)
  end
end
