class App::MembershipsController < App::AppController
  def index
  end
  def show
  end
  def new
    if params[:business_id]
      @business = Business.find(params[:business_id])
      @resource = @business
      @context = @business
      @membership = Membership.new
    else
      @user = User.find(params[:user_id])
      @household = @user.home
      @resource = @household
      @context = @household
      @membership = Membership.new
    end
  end
  def create
  end
  def edit
    if params[:business_id]
      @business = Business.find(params[:business_id])
      @resource = @business
      @context = @business
      @membership = @business.memberships.find_by(:member => User.find(params[:id]))
    else
      @user = User.find(params[:user_id])
      @household = @user.home
      @resource = @household
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
    params.require(:membership).permit(:global_collective,:member)
  end
end