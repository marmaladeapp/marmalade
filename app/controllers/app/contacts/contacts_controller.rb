class App::Contacts::ContactsController < App::AppController

  def index
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @contacts =  @resource.contacts
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @contacts = @household.contacts
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @contacts = @group.contacts
    else
      @contacts = current_user.contacts
      @contacts += ::Contacts::Contact.where(:owner => current_user.businesses.to_a)
      @contacts += ::Contacts::Contact.where(:owner => current_user.households.to_a)
      @contacts += ::Contacts::Contact.where(:owner => current_user.groups.to_a)
    end
  end

  def show
  end

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
      @address_book = ::Contacts::AddressBook.find(params[:address_book_id])
    end
    @contact = ::Contacts::Contact.new
  end

  def edit
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
    @contact = @resource.contacts.new(contact_params)
    @contact.user = @resource.class.name == 'User' ? @resource : @resource.user
    if @contact.save
      redirect_to root_path
    else
      render 'new'
    end
  end

  def update
  end

  def destroy
  end

  private

  def contact_params
    params.require(:contacts_contact).permit(:name,:address_book_id,:global_item)
  end
end
