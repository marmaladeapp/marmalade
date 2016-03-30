class App::Inventory::ItemsController < App::AppController

  def index
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
      @containers =  @resource.containers
      @items =  @resource.inventory_items
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      authorize! :show, @household, :message => ""
      @context = @household
      @containers = @household.containers
      @items = @household.inventory_items
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      authorize! :show, @group, :message => ""
      @context = @group
      @containers = @group.containers
      @items = @group.inventory_items
    else
      @containers = ::Inventory::Container.where(
        '(owner_type = ? AND owner_id = ?) OR 
        (owner_type = ? AND owner_id IN (?)) OR 
        (owner_type = ? AND owner_id IN (?)) OR 
        (owner_type = ? AND owner_id IN (?))', 
        'User', current_user.id, 
        'Business', current_user.businesses.ids, 
        'Household', current_user.households.ids, 
        'Group', current_user.groups.ids
      ).page(params[:page]) #.per(2)
      @items = ::Inventory::Item.where(
        '(context_type = ? AND context_id = ?) OR 
        (context_type = ? AND context_id IN (?)) OR 
        (context_type = ? AND context_id IN (?)) OR 
        (context_type = ? AND context_id IN (?))', 
        'User', current_user.id, 
        'Business', current_user.businesses.ids, 
        'Household', current_user.households.ids, 
        'Group', current_user.groups.ids
      ).page(params[:page]) #.per(2)
    end
  end

  def show
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
      @item =  @context.inventory_items.find(params[:id])
      @containers =  @item.containers
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      authorize! :show, @household, :message => ""
      @context = @household
      @item = @context.inventory_items.find(params[:id])
      @containers = @item.containers
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      authorize! :show, @group, :message => ""
      @context = @group
      @item = @context.inventory_items.find(params[:id])
      @containers = @item.containers
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
    if params[:container_id]
      @container = @resource.containers.find(params[:container_id])
    end
    @item = ::Inventory::Item.new
  end

  def edit
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
      @item =  @context.inventory_items.find(params[:id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @resource = @context
      authorize! :show, @resource, :message => ""
      @item = @context.inventory_items.find(params[:id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @resource = @context
      authorize! :show, @resource, :message => ""
      @item = @context.inventory_items.find(params[:id])
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
      authorize! :show, @resource, :message => ""
      @context = @resource
    end


    @item = @resource.inventory_items.new(item_params)
    if @item.save
      @context.abstracts.create(:item => @item, :user => current_user, :action => 'create')
      if params[:resource_id]
        redirect_to resource_item_path(@resource,@item)
      elsif params[:user_id]
        redirect_to user_home_item_path(@user,@item)
      elsif params[:group_id]
        redirect_to group_item_path(@context,@item)
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
      @item =  @context.inventory_items.find(params[:id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @resource = @context
      authorize! :show, @resource, :message => ""
      @item = @context.inventory_items.find(params[:id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @resource = @context
      authorize! :show, @resource, :message => ""
      @item = @context.inventory_items.find(params[:id])
    end
    if @item.update_attributes(item_params)
      if params[:resource_id]
        redirect_to resource_item_path(@resource,@item)
      elsif params[:user_id]
        redirect_to user_home_item_path(@user,@item)
      elsif params[:group_id]
        redirect_to group_item_path(@context,@item)
      end
    else
      render 'edit'
    end
  end

  def destroy
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
      @item =  @context.inventory_items.find(params[:id])
      @item.destroy
      redirect_to resource_items_path(@resource)
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @resource = @context
      authorize! :show, @resource, :message => ""
      @item = @context.inventory_items.find(params[:id])
      @item.destroy
      redirect_to user_home_items_path(@user)
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @resource = @context
      authorize! :show, @resource, :message => ""
      @item = @context.inventory_items.find(params[:id])
      @item.destroy
      redirect_to group_items_path(@group)
    end
  end

  def containers
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      authorize! :show, @resource, :message => ""
      @context = @resource
      @item =  @context.inventory_items.find(params[:item_id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @resource = @context
      authorize! :show, @resource, :message => ""
      @item = @context.inventory_items.find(params[:item_id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @resource = @context
      authorize! :show, @resource, :message => ""
      @item = @context.inventory_items.find(params[:item_id])
    end
    @containers = @item.containers
  end

  private

  def item_params
    params.require(:inventory_item).permit(:name,:quantity,:consumable,:saleable,:global_item,:owners_attributes => [:user_id,:global_owner])
  end
end
