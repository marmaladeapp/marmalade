class App::Projects::Messages::MessagesController < App::AppController

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

  def message_params
    params.require(:messages_message).permit()
  end
end
