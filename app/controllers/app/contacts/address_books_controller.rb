class App::Contacts::AddressBooksController < App::AppController

  def index
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @address_books =  @resource.address_books
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @address_books = @household.address_books
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
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
      @context = @resource
      @address_book =  @resource.address_books.find(params[:id])
      @contacts = @address_book.contacts
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @address_book = @household.address_books.find(params[:id])
      @contacts = @address_book.contacts
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @address_book = @group.address_books.find(params[:id])
      @contacts = @address_book.contacts
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
    @address_book = ::Contacts::AddressBook.new
  end

  def edit
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @address_book =  @resource.address_books.find(params[:id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @resource = @context
      @address_book = @household.address_books.find(params[:id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @resource = @context
      @address_book = @group.address_books.find(params[:id])
    end
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
    @address_book = @resource.address_books.new(address_book_params)
    @address_book.user = @resource.class.name == 'User' ? @resource : @resource.user
    if @address_book.save
      @context.abstracts.create(:item => @address_book, :user => current_user, :action => 'create')
      redirect_to root_path
    else
      render 'new'
    end
  end

  def update
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @address_book =  @resource.address_books.find(params[:id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @address_book = @household.address_books.find(params[:id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @address_book = @group.address_books.find(params[:id])
    end
    if @address_book.update_attributes(address_book_params)
      redirect_to root_path
    else
      render 'new'
    end
  end

  def destroy
  end

  private

  def address_book_params
    params.require(:contacts_address_book).permit(:name,:description)
  end
end
