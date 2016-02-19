class App::Finances::FinancesController < App::AppController

  def index
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
    else
    end
  end

end
