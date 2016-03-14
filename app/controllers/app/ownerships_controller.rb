class App::OwnershipsController < App::AppController
  def index
  end
  def show
  end
  def new
    @business = Business.find(params[:business_id])
    @resource = @business
    # resource because we want to be able to add owners to wallets and other resources too. Boy, that'll be tricky.
    @context = @business
    @ownership = Ownership.new
    user_ids = []
    business_ids = []
    business_ids << @business.id
    @resource.owners.each do |ownership|
      case ownership.owner.class.name
      when 'User'
        user_ids << ownership.owner.id
      when 'Business'
        business_ids << ownership.owner.id
      end
    end
    Ownership.where(:owner => @business).each do |ownership|
      ownership.ancestries.each do |ancestry|
        ancestry.subtree.each do |descendant|
          business_ids << descendant.ownership.item.id
        end
      end
    end
    @users_for_owner_select = current_user.collaborator_users.where.not(:id => user_ids)
    @businesses_for_owner_select = current_user.subscriber_businesses.where.not(:id => business_ids)
  end
  def create
    @business = Business.find(params[:business_id])
    @resource = @business
    # resource because we want to be able to add owners to wallets and other resources too. Boy, that'll be tricky.
    @context = @business
    @ownership = @resource.owners.new(ownership_params)
    if params[:invite].present?
      if User.find_by(:email => params[:invite]).present?
        @ownership.owner = User.find_by(:email => params[:invite])
        unless current_user.collaborators.where(:collaborator => @ownership.owner).any?
          current_user.collaborators.create(:collaborator => @ownership.owner)
        end
      else
        new_user = User.new(:email => params[:invite])
        new_user.username = "u_" + Array.new(8){ [*'0'..'9',*'A'..'Z',*'a'..'z'].sample }.join
        new_user.invite!(current_user)
        @ownership.owner = new_user
        current_user.collaborators.create(:collaborator => @ownership.owner)
      end
    end
    @ownership.user = @resource.user
    if !@ownership.owner.is_owner?(@ownership.item) && @ownership.save
      @context.abstracts.create(:item => @ownership, :user => current_user, :action => 'create')
      @ownership.owner.abstracts.create(:item => @ownership, :user => current_user, :action => 'create')
      if @ownership.owner.class.name == 'User'
        unless @resource.memberships.where(:member => @ownership.owner).any?
          @resource.memberships.create(:member => @ownership.owner, :user => @resource.user)
        end
      end
      redirect_to vanity_path(@business)
    else
      user_ids = []
      business_ids = []
      business_ids << @business.id
      @resource.owners.each do |ownership|
        case ownership.owner.class.name
        when 'User'
          user_ids << ownership.owner.id
        when 'Business'
          business_ids << ownership.owner.id
        end
      end
      Ownership.where(:owner => @business).each do |ownership|
        ownership.ancestries.each do |ancestry|
          ancestry.subtree.each do |descendant|
            business_ids << descendant.ownership.item.id
          end
        end
      end
      @users_for_owner_select = current_user.collaborator_users.where.not(:id => user_ids)
      @businesses_for_owner_select = current_user.subscriber_businesses.where.not(:id => business_ids)
      render 'new'
    end
  end
  def edit
    @business = Business.find(params[:business_id])
    @resource = @business
    # resource because we want to be able to add owners to wallets and other resources too. Boy, that'll be tricky.
    @context = @business
    @ownership = @business.owners.find_by(:owner => VanityUrl.find_by_slug(params[:id]).owner)
  end
  def update
    @business = Business.find(params[:business_id])
    @resource = @business
    # resource because we want to be able to add owners to wallets and other resources too. Boy, that'll be tricky.
    @context = @business
    @ownership = @business.owners.find_by(:owner => VanityUrl.find_by_slug(params[:id]).owner)
    if @ownership.update_attributes(ownership_params)
      redirect_to vanity_path(@business)
    else
      render 'edit'
    end
  end
  def destroy
    @business = Business.find(params[:business_id])
    @ownership = @business.owners.find_by(:owner => VanityUrl.find_by_slug(params[:id]).owner)
    @ownership.destroy
    redirect_to vanity_path(@business)
  end
  private
  def ownership_params
    params.require(:ownership).permit(:global_owner,:global_item,:equity)
  end
end