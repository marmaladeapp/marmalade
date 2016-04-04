class App::MembershipsController < App::AppController
  def index
  end
  def show
  end
  def new
    if params[:resource_id]
      @business = Business.find(params[:resource_id])
      @resource = @business
      authorize! :show, @resource, :message => ""
      @context = @business
      @membership = Membership.new
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @resource = @group
      authorize! :show, @resource, :message => ""
      @context = @group
      @membership = Membership.new
    else
      @user = User.find(params[:user_id])
      @household = @user.home
      @resource = @household
      authorize! :show, @resource, :message => ""
      @context = @household
      @membership = Membership.new
    end

    if current_user.plan.collaborator_limit.present? && @resource.members.count >= user.plan.collaborator_limit
      authorize! :new, Collaborator, :message => ""
    end

    ids = []
    @resource.members.each do |member|
      ids << member.id
    end
    @options_for_member_select = current_user.collaborator_users.where.not(:id => ids)
  end
  def create
    if params[:resource_id]
      @business = Business.find(params[:resource_id])
      @resource = @business
      authorize! :show, @resource, :message => ""
      @context = @business
      @membership = @resource.memberships.new(membership_params)
      authorize! :create, @membership, :message => ""
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @resource = @group
      authorize! :show, @resource, :message => ""
      @context = @group
      @membership = @resource.memberships.new(membership_params)
      authorize! :create, @membership, :message => ""
    else
      @user = User.find(params[:user_id])
      @household = @user.home
      @resource = @household
      authorize! :show, @resource, :message => ""
      @context = @household
      @membership = @resource.memberships.new(membership_params)
      authorize! :create, @membership, :message => ""
    end
    if params[:invite].present?
      if User.find_by(:email => params[:invite]).present?
        @membership.member = User.find_by(:email => params[:invite])
        unless current_user.collaborators.where(:collaborator => @membership.member).exists?
          authorize! :create, Collaborator, :message => ""
          current_user.collaborators.create(:collaborator => @membership.member)
        end
      else
        new_user = User.new(:email => params[:invite])
        new_user.username = "u_" + Array.new(8){ [*'0'..'9',*'A'..'Z',*'a'..'z'].sample }.join
        new_user.invite!(current_user)
        @membership.member = new_user
        authorize! :create, Collaborator, :message => ""
        current_user.collaborators.create(:collaborator => @membership.member)
      end
    end
    unless params[:resource_id] || params[:group_id]
      if @membership.member && @membership.member.home.present?
        ## Should rescue us from assigning secondary households.
        redirect_to user_home_path(@user) and return
      end
    end
    if @membership.member.class.name == "User" && @membership.member != current_user
      @membership.confirmed = false
    else
      @membership.confirmed = true
    end
    @membership.user = @resource.user
    if @membership.member && !@membership.member.is_member?(@membership.collective) && @membership.save
      @context.abstracts.create(:item => @membership, :user => current_user, :action => 'create')
      @membership.member.abstracts.create(:item => @membership, :user => current_user, :action => 'create')
      if params[:resource_id]
        redirect_to vanity_path(@business)
      elsif params[:group_id]
        redirect_to group_path(@group)
      else
        if @membership.confirmed
          @ownership = @household.ownerships.create(:owner => @household, :item => @membership.member, :equity => BigDecimal.new(100))
          @ownership.update_balance_sheets(:value => @membership.member.net_worth,:current_assets => @membership.member.current_assets,:fixed_assets => @membership.member.fixed_assets,:current_liabilities => @membership.member.current_liabilities,:long_term_liabilities => @membership.member.long_term_liabilities,:cash => @membership.member.cash,:ledgers_receivable => @membership.member.total_ledgers_receivable,:ledgers_debt => @membership.member.total_ledgers_debt,:wallets => @membership.member.total_wallets,:capital_assets => @membership.member.capital_assets,:inventory => @membership.member.inventory,:item => @membership.member,:action => 'update')
        end
        redirect_to user_home_path(@user)
      end
    else
      ids = []
      @resource.members.each do |member|
        ids << member.id
      end
      @options_for_member_select = current_user.collaborator_users.where.not(:id => ids)
      render 'new'
    end
  end
  def edit
    if params[:resource_id]
      @business = Business.find(params[:resource_id])
      @resource = @business
      authorize! :show, @resource, :message => ""
      @context = @business
      @membership = @business.memberships.find_by(:member => User.find(params[:id]))
      authorize! :edit, @membership, :message => ""
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @resource = @group
      authorize! :show, @resource, :message => ""
      @context = @group
      @membership = @group.memberships.find_by(:member => User.find(params[:id]))
      authorize! :edit, @membership, :message => ""
    else
      @user = User.find(params[:user_id])
      @household = @user.home
      @resource = @household
      authorize! :show, @resource, :message => ""
      @context = @household
      @membership = @household.memberships.find_by(:member => User.find(params[:id]))
      authorize! :edit, @membership, :message => ""
    end
  end
  def update
    if params[:resource_id]
      @business = Business.find(params[:resource_id])
      @resource = @business
      authorize! :show, @resource, :message => ""
      @context = @business
      @membership = @business.memberships.find_by(:member => User.find(params[:id]))
      authorize! :update, @membership, :message => ""
      redirect_to vanity_path(@business)
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @resource = @group
      authorize! :show, @resource, :message => ""
      @context = @group
      @membership = @group.memberships.find_by(:member => User.find(params[:id]))
      authorize! :update, @membership, :message => ""
      redirect_to group_path(@group)
    else
      @user = User.find(params[:user_id])
      @household = @user.home
      @resource = @household
      authorize! :show, @resource, :message => ""
      @context = @household
      @membership = @household.memberships.find_by(:member => User.find(params[:id]))
      authorize! :update, @membership, :message => ""
      redirect_to user_home_path(@user)
    end
  end
  def destroy
    if params[:resource_id]
      @business = Business.find(params[:resource_id])
      authorize! :show, @business, :message => ""
      @membership = @business.memberships.find_by(:member => User.find(params[:id]))
      authorize! :destroy, @membership, :message => ""
      unless @membership.member == @business.user
        @membership.destroy
      end
      redirect_to vanity_path(@business)
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      authorize! :show, @group, :message => ""
      @membership = @group.memberships.find_by(:member => User.find(params[:id]))
      authorize! :destroy, @membership, :message => ""
      unless @membership.member == @group.user
        @membership.destroy
      end
      redirect_to group_path(@group)
    else
      @user = User.find(params[:user_id])
      @household = @user.home
      authorize! :show, @household, :message => ""
      @membership = @household.memberships.find_by(:member => User.find(params[:id]))
      authorize! :destroy, @membership, :message => ""
      unless @membership.member == @household.user
        @ownership = @household.ownerships.find_by(:owner => @household, :item => @membership.member)
        @ownership.update_balance_sheets(:value => - @membership.member.net_worth,:current_assets => - @membership.member.current_assets,:fixed_assets => - @membership.member.fixed_assets,:current_liabilities => - @membership.member.current_liabilities,:long_term_liabilities => - @membership.member.long_term_liabilities,:cash => - @membership.member.cash,:ledgers_receivable => - @membership.member.total_ledgers_receivable,:ledgers_debt => - @membership.member.total_ledgers_debt,:wallets => - @membership.member.total_wallets,:capital_assets => - @membership.member.capital_assets,:inventory => - @membership.member.inventory,:item => @membership.member,:action => 'update')
        @ownership.destroy
        @membership.destroy
      end
      redirect_to user_home_path(@user)
    end
  end

  def accept
    if params[:resource_id]
      @business = Business.find(params[:resource_id])
      @resource = @business
      authorize! :show, @resource, :message => ""
      @context = @business
      @membership = @business.memberships.find_by(:member => User.find(params[:id]))
      authorize! :update, @membership, :message => ""
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @resource = @group
      authorize! :show, @resource, :message => ""
      @context = @group
      @membership = @group.memberships.find_by(:member => User.find(params[:id]))
      authorize! :update, @membership, :message => ""
    else
      @user = User.find(params[:user_id])
      @household = @user.home
      @resource = @household
      authorize! :show, @resource, :message => ""
      @context = @household
      @membership = @household.memberships.find_by(:member => User.find(params[:id]))
      authorize! :update, @membership, :message => ""
    end
    if @membership.update_attributes(:confirmed => true)
      if params[:resource_id]
        redirect_to vanity_path(@business)
      elsif params[:group_id]
        redirect_to group_path(@group)
      else
        @ownership = @household.ownerships.create(:owner => @household, :item => @membership.member, :equity => BigDecimal.new(100))
        @ownership.update_balance_sheets(:value => @membership.member.net_worth,:current_assets => @membership.member.current_assets,:fixed_assets => @membership.member.fixed_assets,:current_liabilities => @membership.member.current_liabilities,:long_term_liabilities => @membership.member.long_term_liabilities,:cash => @membership.member.cash,:ledgers_receivable => @membership.member.total_ledgers_receivable,:ledgers_debt => @membership.member.total_ledgers_debt,:wallets => @membership.member.total_wallets,:capital_assets => @membership.member.capital_assets,:inventory => @membership.member.inventory,:item => @membership.member,:action => 'update')
        redirect_to user_home_path(@user)
      end
    else
      redirect_to root_path
    end
  end

  def reject
    if params[:resource_id]
      @business = Business.find(params[:resource_id])
      authorize! :show, @business, :message => ""
      @membership = @business.memberships.find_by(:member => User.find(params[:id]))
      authorize! :destroy, @membership, :message => ""
      unless @membership.member == @business.user
        @membership.destroy
      end
      redirect_to root_path
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      authorize! :show, @group, :message => ""
      @membership = @group.memberships.find_by(:member => User.find(params[:id]))
      authorize! :destroy, @membership, :message => ""
      unless @membership.member == @group.user
        @membership.destroy
      end
      redirect_to root_path
    else
      @user = User.find(params[:user_id])
      @household = @user.home
      authorize! :show, @household, :message => ""
      @membership = @household.memberships.find_by(:member => User.find(params[:id]))
      authorize! :destroy, @membership, :message => ""
      unless @membership.member == @household.user
        @membership.destroy
      end
      redirect_to root_path
    end
  end

  private
  def membership_params
    params.require(:membership).permit(:global_collective,:global_member)
  end
end