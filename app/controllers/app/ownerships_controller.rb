class App::OwnershipsController < App::AppController
  def index
  end
  def show
  end
  def new
  end
  def create
  end
  def edit
    @business = Business.find(params[:business_id])
    @context = @business
    @ownership = @business.owners.find_by(:owner => VanityUrl.find_by_slug(params[:id]).owner)
  end
  def update
  end
  def destroy
  end
  private
  def ownership_params
    params.require(:ownership).permit()
  end
end