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
    ids = []
    @resource.members.each do |member|
      ids << member.id
    end
    @options_for_member_select = current_user.collaborator_users.where.not(:id => ids)
  end
  def create
    if params[:business_id]
      @business = Business.find(params[:business_id])
      @resource = @business
      @context = @business
      @membership = @resource.memberships.new(membership_params)
    else
      @user = User.find(params[:user_id])
      @household = @user.home
      @resource = @household
      @context = @household
      @membership = @resource.memberships.new(membership_params)
    end
    if params[:invite].present?
      if User.find_by(:email => params[:invite]).present?
        @membership.member = User.find_by(:email => params[:invite])
        unless current_user.collaborators.where(:collaborator => @membership.member).exists?
          current_user.collaborators.create(:collaborator => @membership.member)
        end
      else
        new_user = User.new(:email => params[:invite])
        new_user.username = "u_" + Array.new(8){ [*'0'..'9',*'A'..'Z',*'a'..'z'].sample }.join
        new_user.invite!(current_user)
        @membership.member = new_user
        current_user.collaborators.create(:collaborator => @membership.member)
      end
    end
    unless params[:business_id]
      if @membership.member.home.present?
        ## Should rescue us from assigning secondary households.
        redirect_to user_home_path(@user) and return
      end
    end
    @membership.user = @resource.user
    if @membership.save
      if params[:business_id]
        redirect_to vanity_path(@business)
      else
        @household.ownerships.create(:owner => @household, :item => @membership.member, :equity => BigDecimal.new(100))
        redirect_to user_home_path(@user)
      end
    else
      render 'new'
    end
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
    if params[:business_id]
      @business = Business.find(params[:business_id])
      @resource = @business
      @context = @business
      @membership = @business.memberships.find_by(:member => User.find(params[:id]))
      redirect_to vanity_path(@business)
    else
      @user = User.find(params[:user_id])
      @household = @user.home
      @resource = @household
      @context = @household
      @membership = @household.memberships.find_by(:member => User.find(params[:id]))
      redirect_to user_home_path(@user)
    end
  end
  def destroy
    if params[:business_id]
      @business = Business.find(params[:business_id])
      @membership = @business.memberships.find_by(:member => User.find(params[:id]))
      unless @membership.member == @business.user
        @membership.destroy
      end
      redirect_to vanity_path(@business)
    else
      @user = User.find(params[:user_id])
      @household = @user.home
      @membership = @household.memberships.find_by(:member => User.find(params[:id]))
      unless @membership.member == @household.user
        @household.ownerships.find_by(:owner => @household, :item => @membership.member).destroy
        @membership.destroy
      end
      redirect_to user_home_path(@user)
    end
  end
  private
  def membership_params
    params.require(:membership).permit(:global_collective,:global_member)
  end
end