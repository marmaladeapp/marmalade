class App::Projects::Time::TimersController < App::AppController

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

  def timer_params
    params.require(:time_tracking_timer).permit()
  end
end
