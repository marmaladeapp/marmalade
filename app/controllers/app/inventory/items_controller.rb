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
    @stock_sheets = ::Inventory::StockSheet.unscoped.order(created_at: :desc).where(:item => @item).page(params[:page]) #.per(2)
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
    if @resource.class.name == "Household"
      @ownerships = []
      @resource.members.each do |member|
        @ownerships << Ownership.new(:owner => member, :item => @item, :equity => BigDecimal.new(100) / @resource.members.count, :user_id => @resource.user.id)
      end
    else
      @ownerships = []
      @ownerships << Ownership.new(:owner => @resource, :item => @item, :equity => BigDecimal.new(100), :user_id => @resource.class.name == "User" ? @resource.id : @resource.user.id)
    end
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

    params[:inventory_item][:starting_value] = BigDecimal.new(params[:inventory_item][:starting_value])
    @item = @resource.inventory_items.new(item_params)
    unless (@item.quantity == 0 || @item.quantity == nil)
      @item.unit_value = @item.starting_value / @item.quantity
      @item.unit_starting_value = @item.unit_value
      @item.value = @item.starting_value
    end
    @item.total_quantity = @item.quantity
    @item.currency = @context.currency

    if @item.quantity != 0 && @item.save
      @context.abstracts.create(:item => @item, :user => current_user, :action => 'create')
      @item.stock_sheets.create(:quantity => @item.quantity, :quantity_difference => @item.quantity, :unit_value => @item.unit_value, :unit_value_difference => @item.unit_value, :total_value => @item.value, :total_value_difference => @item.value, :currency => @item.currency)

      if false # wallety_wallet, yknow paymenty payment
      end

      @item.owners.each do |ownership|
        if @item.saleable
          ownership.update_balance_sheets(:value => @item.value,:current_assets => @item.value,:inventory => @item.value,:item => @item,:action => 'create')
        elsif !@item.consumable
          ownership.update_balance_sheets(:value => @item.value,:fixed_assets => @item.value,:capital_assets => @item.value,:item => @item,:action => 'create')
        end
      end

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
      @item.owners.each do |ownership|
        if @item.saleable
          ownership.update_balance_sheets(:value => - @item.value,:current_assets => - @item.value,:inventory => - @item.value,:item => @item,:action => 'destroy')
        elsif !@item.consumable
          ownership.update_balance_sheets(:value => - @item.value,:fixed_assets => - @item.value,:capital_assets => - @item.value,:item => @item,:action => 'destroy')
        end
      end
      @item.destroy
      redirect_to resource_items_path(@resource)
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @resource = @context
      authorize! :show, @resource, :message => ""
      @item = @context.inventory_items.find(params[:id])
      @item.owners.each do |ownership|
        if @item.saleable
          ownership.update_balance_sheets(:value => - @item.value,:current_assets => - @item.value,:inventory => - @item.value,:item => @item,:action => 'destroy')
        elsif !@item.consumable
          ownership.update_balance_sheets(:value => - @item.value,:fixed_assets => - @item.value,:capital_assets => - @item.value,:item => @item,:action => 'destroy')
        end
      end
      @item.destroy
      redirect_to user_home_items_path(@user)
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @resource = @context
      authorize! :show, @resource, :message => ""
      @item = @context.inventory_items.find(params[:id])
      @item.owners.each do |ownership|
        if @item.saleable
          ownership.update_balance_sheets(:value => - @item.value,:current_assets => - @item.value,:inventory => - @item.value,:item => @item,:action => 'destroy')
        elsif !@item.consumable
          ownership.update_balance_sheets(:value => - @item.value,:fixed_assets => - @item.value,:capital_assets => - @item.value,:item => @item,:action => 'destroy')
        end
      end
      @item.destroy
      redirect_to group_items_path(@group)
    end
  end

  def consume
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
    if params[:commit] == 'consume'
      @item.quantity = @item.quantity - params[:inventory_item][:consumption].to_i
      @item.value = @item.value - (@item.unit_value * params[:inventory_item][:consumption].to_i)
      if !(@item.quantity < 0) && @item.save
        @context.abstracts.create(:item => @item, :user => current_user, :action => 'update')
        @item.stock_sheets.create(:quantity => @item.quantity, :quantity_difference => @item.quantity - @item.stock_sheets.last.quantity, :unit_value => @item.unit_value, :unit_value_difference => 0, :total_value => @item.value, :total_value_difference => @item.value - @item.stock_sheets.last.total_value, :currency => @item.currency)
      @item.owners.each do |ownership|
        if @item.saleable
          ownership.update_balance_sheets(:value => stock.total_value_difference,:current_assets => stock.total_value_difference,:inventory => stock.total_value_difference,:item => @item,:action => 'update')
        elsif !@item.consumable
          ownership.update_balance_sheets(:value => stock.total_value_difference,:fixed_assets => stock.total_value_difference,:capital_assets => stock.total_value_difference,:item => @item,:action => 'update')
        end
      end
        if params[:resource_id]
          redirect_to resource_item_path(@resource,@item)
        elsif params[:user_id]
          redirect_to user_home_item_path(@user,@item)
        elsif params[:group_id]
          redirect_to group_item_path(@context,@item)
        end
      else
        if params[:resource_id]
          redirect_to resource_item_path(@resource,@item)
        elsif params[:user_id]
          redirect_to user_home_item_path(@user,@item)
        elsif params[:group_id]
          redirect_to group_item_path(@context,@item)
        end
      end
    else
      case params[:commit]
      when 'purchase'
        render 'purchase'
      when 'sell'
        render 'sell'
      end
    end
  end

  def purchase
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

    params[:inventory_item][:purchase_value] = BigDecimal.new(params[:inventory_item][:purchase_value])
    @item.starting_value = @item.starting_value + params[:inventory_item][:purchase_value].to_d
    @item.quantity = @item.quantity + params[:inventory_item][:consumption].to_i
    @item.total_quantity = @item.total_quantity + params[:inventory_item][:consumption].to_i
    @item.unit_value = @item.starting_value / @item.total_quantity
    @item.value = @item.value + params[:inventory_item][:purchase_value].to_d
    @item.unit_starting_value = @item.starting_value / @item.total_quantity

    if @item.save
      @context.abstracts.create(:item => @item, :user => current_user, :action => 'update')
      stock = @item.stock_sheets.create(:quantity => @item.quantity, :quantity_difference =>  @item.quantity - @item.stock_sheets.last.quantity, :unit_value => @item.unit_value, :unit_value_difference =>  @item.unit_value - @item.stock_sheets.last.unit_value, :total_value => @item.value, :total_value_difference =>  @item.unit_value - @item.stock_sheets.last.total_value, :currency => @item.currency)
      @item.owners.each do |ownership|
        if @item.saleable
          ownership.update_balance_sheets(:value => stock.total_value_difference,:current_assets => stock.total_value_difference,:inventory => stock.total_value_difference,:item => @item,:action => 'update')
        elsif !@item.consumable
          ownership.update_balance_sheets(:value => stock.total_value_difference,:fixed_assets => stock.total_value_difference,:capital_assets => stock.total_value_difference,:item => @item,:action => 'update')
        end
      end
      if params[:resource_id]
        redirect_to resource_item_path(@resource,@item)
      elsif params[:user_id]
        redirect_to user_home_item_path(@user,@item)
      elsif params[:group_id]
        redirect_to group_item_path(@context,@item)
      end
    else
      if params[:resource_id]
        redirect_to resource_item_path(@resource,@item)
      elsif params[:user_id]
        redirect_to user_home_item_path(@user,@item)
      elsif params[:group_id]
        redirect_to group_item_path(@context,@item)
      end
    end
  end

  def sell
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

    params[:inventory_item][:sale_value] = BigDecimal.new(params[:inventory_item][:sale_value])
    @item.ending_value = @item.ending_value + params[:inventory_item][:sale_value].to_d
    @item.quantity = @item.quantity - params[:inventory_item][:consumption].to_i

    @item.total_sold = @item.total_sold + params[:inventory_item][:consumption].to_i
    @item.value = @item.value - (@item.unit_value * params[:inventory_item][:consumption].to_i)

    if @item.total_sold
      @item.unit_ending_value = @item.ending_value / @item.total_sold
    else
      @item.unit_ending_value = @item.ending_value / params[:inventory_item][:consumption].to_i
    end

    if !(@item.quantity < 0) && @item.save
      @context.abstracts.create(:item => @item, :user => current_user, :action => 'update')
      @item.stock_sheets.create(:quantity => @item.quantity, :quantity_difference => @item.quantity - @item.stock_sheets.last.quantity, :unit_value => @item.unit_value, :unit_value_difference => 0, :total_value => @item.value, :total_value_difference => @item.value - @item.stock_sheets.last.total_value, :currency => @item.currency)
      @item.owners.each do |ownership|
        if @item.saleable
          ownership.update_balance_sheets(:value => stock.total_value_difference,:current_assets => stock.total_value_difference,:inventory => stock.total_value_difference,:item => @item,:action => 'update')
        elsif !@item.consumable
          ownership.update_balance_sheets(:value => stock.total_value_difference,:fixed_assets => stock.total_value_difference,:capital_assets => stock.total_value_difference,:item => @item,:action => 'update')
        end
      end
      if params[:resource_id]
        redirect_to resource_item_path(@resource,@item)
      elsif params[:user_id]
        redirect_to user_home_item_path(@user,@item)
      elsif params[:group_id]
        redirect_to group_item_path(@context,@item)
      end
    else
      if params[:resource_id]
        redirect_to resource_item_path(@resource,@item)
      elsif params[:user_id]
        redirect_to user_home_item_path(@user,@item)
      elsif params[:group_id]
        redirect_to group_item_path(@context,@item)
      end
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
    params.require(:inventory_item).permit(:name,:quantity,:starting_value,:currency,:consumable,:saleable,:global_item,:categories_attributes => [:global_category],:owners_attributes => [:user_id,:global_owner,:equity])
  end
end
