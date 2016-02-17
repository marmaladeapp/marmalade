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
    else
      @address_books = current_user.address_books
      @address_books += ::Contacts::AddressBook.where(:owner => current_user.businesses.to_a)
      @address_books += ::Contacts::AddressBook.where(:owner => current_user.households.to_a)
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
    end
    @address_book = ::Contacts::AddressBook.new
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
    end
    @address_book = @resource.address_books.new(address_book_params)
    @address_book.user = @resource.class.name == 'User' ? @resource : @resource.user
    if @address_book.save
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

  def address_book_params
    params.require(:contacts_address_book).permit(:name,:description)
  end
end
