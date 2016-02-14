class App::MembershipsController < App::AppController
  def index
  end
  def show
  end
  def new
  end
  def create
  end
  def edit
    if params[:business_id]
      @business = Business.find(params[:business_id])
      @context = @business
      @membership = @business.memberships.find_by(:member => User.find(params[:id]))
    else
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @membership = @household.memberships.find_by(:member => User.find(params[:id]))
    end
  end
  def update
  end
  def destroy
  end
  private
  def membership_params
    params.require(:membership).permit()
  end
end