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
    ids = []
    @resource.owners.each do |ownership|
      ids << ownership.owner.id
    end
    @options_for_owner_select = current_user.collaborator_users.where.not(:id => ids)
  end
  def create
    @business = Business.find(params[:business_id])
    @resource = @business
    # resource because we want to be able to add owners to wallets and other resources too. Boy, that'll be tricky.
    @context = @business
    @ownership = @resource.owners.new(ownership_params)
    if params[:invite]
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
    if @ownership.save
      unless @resource.memberships.where(:member => @ownership.owner).any?
        @resource.memberships.create(:member => @ownership.owner, :user => @resource.user)
      end
      redirect_to vanity_path(@business)
    else
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
    unless @ownership.owner == @business.user
      @ownership.destroy
    end
    redirect_to vanity_path(@business)
  end
  private
  def ownership_params
    params.require(:ownership).permit(:global_owner,:global_item,:equity)
  end
end