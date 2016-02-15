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
  end
  def create
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