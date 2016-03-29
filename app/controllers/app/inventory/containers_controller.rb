class App::Inventory::ContainersController < App::AppController

  def index
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
      @containers =  @resource.containers
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      authorize! :show, @household, :message => ""
      @context = @household
      @containers = @household.containers
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      authorize! :show, @group, :message => ""
      @context = @group
      @containers = @group.containers
    else
      @containers = current_user.containers
      @containers += ::Inventory::Container.where(:owner => current_user.businesses.to_a)
      @containers += ::Inventory::Container.where(:owner => current_user.households.to_a)
      @containers += ::Inventory::Container.where(:owner => current_user.groups.to_a)
    end
  end

  def show
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
      @container =  @resource.containers.find(params[:id])
      @items = @container.inventory_items
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      authorize! :show, @household, :message => ""
      @context = @household
      @container = @household.containers.find(params[:id])
      @items = @container.inventory_items
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      authorize! :show, @group, :message => ""
      @container = @group.containers.find(params[:id])
      @items = @container.inventory_items
    end
  end

  def new
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      authorize! :show, @resource, :message => ""
      @context = @resource
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      authorize! :show, @resource, :message => ""
      @context = @resource
    end
    @container = ::Inventory::Container.new
  end

  def edit
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
      @container =  @resource.containers.find(params[:id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @resource = @context
      authorize! :show, @resource, :message => ""
      @container = @household.containers.find(params[:id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @resource = @context
      authorize! :show, @resource, :message => ""
      @container = @group.containers.find(params[:id])
    end
  end

  def create
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      authorize! :show, @resource, :message => ""
      @context = @resource
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
      authorize! :show, @resource, :message => ""
    end
    @container = @resource.containers.new(container_params)
    @container.user = @resource.class.name == 'User' ? @resource : @resource.user
    if @container.save
      @context.abstracts.create(:item => @container, :user => current_user, :action => 'create')
      if params[:resource_id]
        redirect_to resource_container_path(@resource,@container)
      elsif params[:user_id]
        redirect_to user_home_container_path(@user,@container)
      elsif params[:group_id]
        redirect_to group_container_path(@context,@container)
      end
    else
      render 'new'
    end
  end

  def update
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
      @container =  @resource.containers.find(params[:id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      authorize! :show, @household, :message => ""
      @context = @household
      @container = @household.containers.find(params[:id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      authorize! :show, @group, :message => ""
      @context = @group
      @container = @group.containers.find(params[:id])
    end
    if @container.update_attributes(container_params)
      if params[:resource_id]
        redirect_to resource_container_path(@resource,@container)
      elsif params[:user_id]
        redirect_to user_home_container_path(@user,@container)
      elsif params[:group_id]
        redirect_to group_container_path(@context,@container)
      end
    else
      render 'new'
    end
  end

  def destroy
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
      @container =  @resource.containers.find(params[:id])
      @container.destroy
      redirect_to resource_items_path(@resource)
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      authorize! :show, @household, :message => ""
      @context = @household
      @container = @household.containers.find(params[:id])
      @container.destroy
      redirect_to user_home_items_path(@user)
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      authorize! :show, @group, :message => ""
      @context = @group
      @container = @group.containers.find(params[:id])
      @container.destroy
      redirect_to group_items_path(@group)
    end
  end

  private

  def container_params
    params.require(:inventory_container).permit(:name,:description)
  end
end
