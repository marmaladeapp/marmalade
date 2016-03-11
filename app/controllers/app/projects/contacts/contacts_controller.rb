class App::Projects::Contacts::ContactsController < App::AppController

  def index
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
  end

  def destroy
  end

  private

  def contact_params
    params.require(:contacts_contact).permit()
  end
end
