class App::UsersController < App::AppController
  def show
    @user = User.find(params[:id])
  end
  def edit
    @user = User.find(params[:id])
  end
  def update
  end
  def subscription
    @user = User.find(params[:user_id])
    gon.client_token = Braintree::ClientToken.generate
    @plans = Plan.all
  end
end
