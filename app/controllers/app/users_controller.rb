class App::UsersController < App::AppController
  def show
    @user = User.find(params[:id])
    if @user == current_user
      @context = @user
      @abstracts = @user.abstracts
    end
  end
  def edit
    @user = User.find(params[:id])
    authorize! :manage, @user, :message => ""
    @context = @user
    redirect_to root_path if current_user != @user
  end
  def profile
    @user = User.find(params[:user_id])
    authorize! :manage, @user, :message => ""
    @context = @user
    redirect_to root_path if current_user != @user
  end
  def password
    @user = User.find(params[:user_id])
    authorize! :manage, @user, :message => ""
    @context = @user
    redirect_to root_path if current_user != @user
  end
  def billing
    @user = User.find(params[:user_id])
    authorize! :manage, @user, :message => ""
    @context = @user
    redirect_to root_path if current_user != @user
    if @user.payment_methods.any?
      @card = Braintree::PaymentMethod.find(@user.payment_methods.first.braintree_payment_method_token)
    end
    gon.client_token = Braintree::ClientToken.generate(
      :customer_id => @user.braintree_customer_id
    )
  end
  def update
    @user = User.find(params[:id])
    authorize! :manage, @user, :message => ""
    redirect_to root_path if current_user != @user
    if !(@user.first_name || @user.last_name) && (params[:user][:first_name] && params[:user][:last_name])
      result = Braintree::Customer.create(
        :first_name => params[:user][:first_name],
        :last_name => params[:user][:last_name],
        :email => @user.email
      )
      @user.braintree_customer_id = result.customer.id
    end
    if params[:payment_method_nonce]
      r = Braintree::PaymentMethod.create(
        :customer_id => @user.braintree_customer_id,
        :payment_method_nonce => params[:payment_method_nonce]
      )
      @user.payment_methods.create(:braintree_payment_method_token => r.payment_method.token)
      result = Braintree::Subscription.create(
        :payment_method_token => r.payment_method.token,
        :plan_id => Plan.find(params[:user][:plan_id]).slug,
        :merchant_account_id => ENV["BRAINTREE_MERCHANT_ACCOUNT_ID"]
      )
      @user.braintree_subscription_id = result.subscription.id
    end
    if @user.update_attributes(user_params)
      redirect_to root_path
    else
      render 'edit'
    end
  end
  def update_password
    @user = User.find(current_user.id)
    authorize! :manage, @user, :message => ""
    redirect_to root_path if current_user != @user
    if @user.update_with_password(user_params)
      # Sign in the user by passing validation in case their password changed
      sign_in @user, :bypass => true
      redirect_to root_path
    else
      render "password"
    end
  end
  def subscription
    @user = User.find(params[:user_id])
    authorize! :manage, @user, :message => ""
    @context = @user
    redirect_to root_path if current_user != @user
    if @user.plan
      @plan = @user.plan
    end
    #gon.client_token = Braintree::ClientToken.generate
    @plans = Plan.order('id ASC').all
    # @plans = Plan.where(:billing_frequency => 1).all
    # the idea being... we sorta just want to show a selection of the plans... and select duration separately. And have like.. an interactive price update-a-majig!
  end
  def payment
    @user = User.find(params[:user_id])
    authorize! :manage, @user, :message => ""
    redirect_to root_path if current_user != @user
    if @user.braintree_subscription_id
      redirect_to root_path
    end
    gon.client_token = Braintree::ClientToken.generate(
      :customer_id => @user.braintree_customer_id
    )
    @plans = Plan.all
    # @plans = Plan.where(:billing_frequency => 1).all
    # the idea being... we sorta just want to show a selection of the plans... and select duration separately. And have like.. an interactive price update-a-majig!
  end
  def update_payment
    @user = User.find(params[:user_id])
    authorize! :manage, @user, :message => ""
    redirect_to root_path if current_user != @user
    if params[:payment_method_nonce]
      r = Braintree::PaymentMethod.create(
        :customer_id => @user.braintree_customer_id,
        :payment_method_nonce => params[:payment_method_nonce]
      )
      if @user.braintree_subscription_id
        Braintree::Subscription.update(
          @user.braintree_subscription_id,
          :payment_method_token => r.payment_method.token
        )
      end
      Braintree::PaymentMethod.delete(@user.payment_methods.first.braintree_payment_method_token)
      @user.payment_methods.first.update_attributes(:braintree_payment_method_token => r.payment_method.token)
    end
    if @user.update_attributes(user_params)
      redirect_to root_path
    else
      render 'billing'
    end
  end

  def subscribe
    @user = User.find(params[:user_id])
    authorize! :manage, @user, :message => ""
    redirect_to root_path if current_user != @user
    if (params[:user][:first_name] && params[:user][:last_name])
      result = Braintree::Customer.create(
        :first_name => params[:user][:first_name],
        :last_name => params[:user][:last_name],
        :email => @user.email
      )
      @user.braintree_customer_id = result.customer.id
    end
    if @user.update_attributes(user_params)
      redirect_to root_path
    else
      render 'subscription'
    end
  end
  def update_subscription
    @user = User.find(params[:user_id])
    authorize! :manage, @user, :message => ""
    redirect_to root_path if current_user != @user
    plan = Plan.find(params[:user][:plan_id])
    unless @user.plan == plan
      if !@user.braintree_subscription_id
        if @user.payment_methods.any?
          result = Braintree::Subscription.create(
            :payment_method_token => @user.payment_methods.first.braintree_payment_method_token,
            :plan_id => plan.slug,
            :merchant_account_id => ENV["BRAINTREE_MERCHANT_ACCOUNT_ID"]
          )
          @user.braintree_subscription_id = result.subscription.id
        else
          # nothing to do; flow continues
        end
      elsif @user.plan.billing_frequency == plan.billing_frequency
        Braintree::Subscription.update(
          @user.braintree_subscription_id,
          :price => plan.price.to_s,
          :plan_id => plan.slug
        )
      else
        # TODO: Because Braintree can't update from monthly to yearly, we have to do this.
        # But what if our users downgrade from a yearly to monthly plan? We'll be charging them
        # even though they ought to have credit in their account?
        r = Braintree::Subscription.cancel(@user.braintree_subscription_id)
        if plan.slug == "free"
          @user.braintree_subscription_id = nil
        else
          result = Braintree::Subscription.create(
            :payment_method_token => r.subscription.payment_method_token,
            :plan_id => plan.slug,
            :merchant_account_id => ENV["BRAINTREE_MERCHANT_ACCOUNT_ID"]
          )
          @user.braintree_subscription_id = result.subscription.id
        end
      end
      @user.plan = plan
    end
    if @user.update_attributes(user_params)
      redirect_to root_path
    else
      render 'subscription'
    end
  end

  def pay_subscription
    @user = User.find(params[:user_id])
    authorize! :manage, @user, :message => ""
    redirect_to root_path if current_user != @user
    if params[:payment_method_nonce]
      r = Braintree::PaymentMethod.create(
        :customer_id => @user.braintree_customer_id,
        :payment_method_nonce => params[:payment_method_nonce]
      )
      @user.payment_methods.create(:braintree_payment_method_token => r.payment_method.token)
      result = Braintree::Subscription.create(
        :payment_method_token => r.payment_method.token,
        :plan_id => Plan.find(params[:user][:plan_id]).slug,
        :merchant_account_id => ENV["BRAINTREE_MERCHANT_ACCOUNT_ID"]
      )
      @user.braintree_subscription_id = result.subscription.id
    end
    if @user.update_attributes(user_params)
      redirect_to root_path
    else
      render 'payment'
    end
  end

  private
  def user_params
    params.require(:user).permit(:username, :first_name, :last_name, :bio, :country, :language, :time_zone, :currency, :plan_id, :payment_method_nonce, :password, :password_confirmation, :current_password)
  end
end
