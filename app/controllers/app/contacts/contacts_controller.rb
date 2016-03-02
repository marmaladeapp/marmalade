class App::Contacts::ContactsController < App::AppController

  def index
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @address_books =  @resource.address_books
      @contacts =  @resource.contacts
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @address_books = @household.address_books
      @contacts = @household.contacts
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @address_books = @group.address_books
      @contacts = @group.contacts
    else
      @address_books = ::Contacts::AddressBook.where(
        '(owner_type = ? AND owner_id = ?) OR 
        (owner_type = ? AND owner_id IN (?)) OR 
        (owner_type = ? AND owner_id IN (?)) OR 
        (owner_type = ? AND owner_id IN (?))', 
        'User', current_user.id, 
        'Business', current_user.businesses.ids, 
        'Household', current_user.households.ids, 
        'Group', current_user.groups.ids
      ).page(params[:page]) #.per(2)
      @contacts = ::Contacts::Contact.where(
        '(context_type = ? AND context_id = ?) OR 
        (context_type = ? AND context_id IN (?)) OR 
        (context_type = ? AND context_id IN (?)) OR 
        (context_type = ? AND context_id IN (?))', 
        'User', current_user.id, 
        'Business', current_user.businesses.ids, 
        'Household', current_user.households.ids, 
        'Group', current_user.groups.ids
      ).page(params[:page]) #.per(2)
    end
  end

  def show
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @contact =  ::Contacts::Contact.find(params[:id])
      @address_books =  @contact.address_books
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @contact = ::Contacts::Contact.find(params[:id])
      @address_books = @contact.address_books
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @contact = ::Contacts::Contact.find(params[:id])
      @address_books = @contact.address_books
    end
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

    unless params[:contacts_contact][:telephones_attributes]["0"][:number].blank?
      params[:contacts_contact][:telephones_attributes]["0"][:number] = PhonyRails.normalize_number(params[:contacts_contact][:telephones_attributes]["0"][:number], default_country_code: params[:contacts_contact][:addresses_attributes]["0"][:country])
    end

    @contact = @resource.contacts.new(contact_params)
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
    params.require(:contacts_contact).permit(:name,:global_item,:emails_attributes => [:address],:addresses_attributes => [:line_1,:line_2,:city,:state,:zip,:country],:telephones_attributes => [:number],:memberships_attributes => [:user_id,:global_collective])
  end
end
