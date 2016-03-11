class App::Projects::Calendar::EventsController < App::AppController

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

  def event_params
    params.require(:calendar_events).permit()
  end
end
