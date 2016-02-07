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
    # @plans = Plan.where(:billing_frequency => 1).all
    # the idea being... we sorta just want to show a selection of the plans... and select duration separately. And have like.. an interactive price update-a-majig!
  end
end
