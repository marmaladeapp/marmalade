class App::Contacts::AddressBooksController < App::AppController

  def index
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
      @address_books =  @resource.address_books
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      authorize! :show, @household, :message => ""
      @context = @household
      @address_books = @household.address_books
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      authorize! :show, @group, :message => ""
      @context = @group
      @address_books = @group.address_books
    else
      @address_books = current_user.address_books
      @address_books += ::Contacts::AddressBook.where(:owner => current_user.businesses.to_a)
      @address_books += ::Contacts::AddressBook.where(:owner => current_user.households.to_a)
      @address_books += ::Contacts::AddressBook.where(:owner => current_user.groups.to_a)
    end
  end

  def show
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
      @address_book =  @resource.address_books.find(params[:id])
      @contacts = @address_book.contacts
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      authorize! :show, @household, :message => ""
      @context = @household
      @address_book = @household.address_books.find(params[:id])
      @contacts = @address_book.contacts
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      authorize! :show, @group, :message => ""
      @address_book = @group.address_books.find(params[:id])
      @contacts = @address_book.contacts
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
    @address_book = ::Contacts::AddressBook.new
  end

  def edit
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
      @address_book =  @resource.address_books.find(params[:id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @resource = @context
      authorize! :show, @resource, :message => ""
      @address_book = @household.address_books.find(params[:id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @resource = @context
      authorize! :show, @resource, :message => ""
      @address_book = @group.address_books.find(params[:id])
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
      @context = @resource
      authorize! :show, @resource, :message => ""
    end
    @address_book = @resource.address_books.new(address_book_params)
    @address_book.user = @resource.class.name == 'User' ? @resource : @resource.user
    if @address_book.save
      @context.abstracts.create(:item => @address_book, :user => current_user, :action => 'create')
      if params[:resource_id]
        redirect_to resource_address_book_path(@resource,@address_book)
      elsif params[:user_id]
        redirect_to user_home_address_book_path(@user,@address_book)
      elsif params[:group_id]
        redirect_to group_address_book_path(@context,@address_book)
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
      @address_book =  @resource.address_books.find(params[:id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      authorize! :show, @household, :message => ""
      @context = @household
      @address_book = @household.address_books.find(params[:id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      authorize! :show, @group, :message => ""
      @context = @group
      @address_book = @group.address_books.find(params[:id])
    end
    if @address_book.update_attributes(address_book_params)
      if params[:resource_id]
        redirect_to resource_address_book_path(@resource,@address_book)
      elsif params[:user_id]
        redirect_to user_home_address_book_path(@user,@address_book)
      elsif params[:group_id]
        redirect_to group_address_book_path(@context,@address_book)
      end
    else
      render 'new'
    end
  end

  def destroy
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
      @address_book =  @resource.address_books.find(params[:id])
      @address_book.destroy
      redirect_to resource_contacts_path(@resource)
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      authorize! :show, @household, :message => ""
      @context = @household
      @address_book = @household.address_books.find(params[:id])
      @address_book.destroy
      redirect_to user_home_contacts_path(@user)
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      authorize! :show, @group, :message => ""
      @context = @group
      @address_book = @group.address_books.find(params[:id])
      @address_book.destroy
      redirect_to group_contacts_path(@group)
    end
  end

  private

  def address_book_params
    params.require(:contacts_address_book).permit(:name,:description)
  end
end
