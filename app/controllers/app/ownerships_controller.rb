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
        #invitey blips.
      end
    end
    if @ownership.save
      unless @resource.memberships.where(:member => @ownership.owner).any?
        @resource.memberships.create(:member => @ownership.owner)
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
  end
  def destroy
  end
  private
  def ownership_params
    params.require(:ownership).permit(:global_owner,:global_item,:equity)
  end
end