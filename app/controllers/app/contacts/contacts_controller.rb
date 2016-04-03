class App::Contacts::ContactsController < App::AppController

  def index
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
      @address_books =  @resource.address_books.limit(3)
      @contacts =  @resource.contacts
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      authorize! :show, @household, :message => ""
      @context = @household
      @address_books = @household.address_books.limit(3)
      @contacts = @household.contacts
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      authorize! :show, @group, :message => ""
      @context = @group
      @address_books = @group.address_books.limit(3)
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
      ).limit(3)
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
      authorize! :show, @resource, :message => ""
      @context = @resource
      @contact =  @context.contacts.find(params[:id])
      @address_books =  @contact.address_books
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      authorize! :show, @household, :message => ""
      @context = @household
      @contact = @context.contacts.find(params[:id])
      @address_books = @contact.address_books
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      authorize! :show, @group, :message => ""
      @context = @group
      @contact = @context.contacts.find(params[:id])
      @address_books = @contact.address_books
    end
  end

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
    if params[:address_book_id]
      @address_book = @resource.address_books.find(params[:address_book_id])
    end
    @contact = ::Contacts::Contact.new
  end

  def edit
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
      @contact =  @context.contacts.find(params[:id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @resource = @context
      authorize! :show, @resource, :message => ""
      @contact = @context.contacts.find(params[:id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @resource = @context
      authorize! :show, @resource, :message => ""
      @contact = @context.contacts.find(params[:id])
    end
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


    @contact = @resource.contacts.new(contact_params)
    if @contact.save
      @context.abstracts.create(:item => @contact, :user => current_user, :action => 'create')
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
      @contact =  @context.contacts.find(params[:id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @resource = @context
      authorize! :show, @resource, :message => ""
      @contact = @context.contacts.find(params[:id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @resource = @context
      authorize! :show, @resource, :message => ""
      @contact = @context.contacts.find(params[:id])
    end
    if @contact.update_attributes(contact_params)
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
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
      @contact =  @context.contacts.find(params[:id])
      @contact.destroy
      redirect_to resource_contacts_path(@resource)
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @resource = @context
      authorize! :show, @resource, :message => ""
      @contact = @context.contacts.find(params[:id])
      @contact.destroy
      redirect_to user_home_contacts_path(@user)
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @resource = @context
      authorize! :show, @resource, :message => ""
      @contact = @context.contacts.find(params[:id])
      @contact.destroy
      redirect_to group_contacts_path(@group)
    end
  end

  def address_books
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
      @contact =  @context.contacts.find(params[:contact_id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @resource = @context
      authorize! :show, @resource, :message => ""
      @contact = @context.contacts.find(params[:contact_id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @resource = @context
      authorize! :show, @resource, :message => ""
      @contact = @context.contacts.find(params[:contact_id])
    end
    @address_books = @contact.address_books
  end

  private

  def contact_params
    params.require(:contacts_contact).permit(:name,:global_item,:emails_attributes => [:address],:addresses_attributes => [:line_1,:line_2,:city,:state,:zip,:country],:telephones_attributes => [:country_code,:number],:owners_attributes => [:user_id,:global_owner,:id,:_destroy])
  end
end
