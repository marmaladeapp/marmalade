class App::Inventory::ChartsController < App::AppController

  before_filter :authenticate_user! # Note that this is a temporary solution; we should make use of cancancan and rolify here AND take account for businesses as owners (don't want to restrict by user ownership then)
  # TODO FIXME fuck_it: see above note - currently only ensuring user is logged in

  # Note: It would be awesome also to date_trunc by half_hour, quarter_hour or other arbitrary but unsupported measure of time
  # See http://stackoverflow.com/questions/12165827/date-trunc-5-minute-interval-in-postgresql for possible solution.
  # It is, however, absolutely possible and supported to do 'minutely' and 'secondly' - how small is too small? Also support for microsecond and millisecond

  # NOTE: Search "Note the repetition of DateTime.now" & "Why not interval_periods as well?"
  # If you could intelligently set something like from_date and to_date and send those across with the request...
  # ...this might solve your repetition problem AND allow for more robust work to be done here too. :)

  def stock_history
    case params[:resource_type]
    when "User"
      @context = User.find(params[:resource_id])
    when "Business"
      @context = Business.find(params[:resource_id])
    when "Household"
      @context = Household.find(params[:resource_id])
    when "Group"
      @context = Group.find(params[:resource_id])
    end
    authorize! :show, @context, :message => "" # TODO: Modifications for can :finance ability. Clearly necessary.
    @user = current_user
    @item = ::Inventory::Item.find(params[:item_id])

    balances = []
    balances << {:created_at => DateTime.now, :balance => @item.quantity} # now why oh why is this not working?

    if params[:interval_period] == "minutely"
      payments = ::Inventory::StockSheet.unscoped.order(created_at: :asc).where(:item => @item).where(:created_at => ::Inventory::StockSheet.unscoped.order(created_at: :asc).where(:item => @item).select("max(created_at) as created_at").group("date_trunc('minute',created_at)"), :created_at => (DateTime.now - 1.hour)..DateTime.now)
      payments.reverse_order.each do |p|
        balances << {:created_at => p.created_at, :balance => p.quantity}
      end
      if ::Inventory::StockSheet.unscoped.order(created_at: :asc).where(:item => @item).first.created_at < 1.hour.ago
        last_hour = ::Inventory::StockSheet.unscoped.order(created_at: :asc).where(:item => @item).where(:created_at => ::Inventory::StockSheet.unscoped.order(created_at: :asc).where(:item => @item).first.created_at..(DateTime.now - 1.hour)).select(:quantity).last
        balances << {:created_at => (DateTime.now - 1.hour), :balance => last_hour.quantity}
      end
      @minutes = []
      @minutely_balance = {}
      balances.each do |v|
        t = v[:created_at].to_time.change(sec: 0, usec: 0)
        unless @minutes.include?(t)
          unless @minutes.empty?
            diff = (((@minutes.last - t) / 1.minute) - 1).round
            diff.times do |n|
              time = @minutes.last - 1.minute
              @minutes << time
              @minutely_balance.merge!(time.in_time_zone(@user.time_zone).strftime("%H:%M") => v[:balance].to_s)
            end
          end
          @minutes << t
          unless @minutely_balance[t.in_time_zone(@user.time_zone).strftime("%H:%M")]
            @minutely_balance.merge!(t.in_time_zone(@user.time_zone).strftime("%H:%M") => v[:balance].to_s)
          end
        end
      end
      render json: @minutely_balance.to_a.reverse.to_h
    elsif params[:interval_period] == "hourly"
      payments = ::Inventory::StockSheet.unscoped.order(created_at: :asc).where(:item => @item).where(:created_at => ::Inventory::StockSheet.unscoped.order(created_at: :asc).where(:item => @item).select("max(created_at) as created_at").group("date_trunc('hour',created_at)"), :created_at => (DateTime.now - 24.hours)..DateTime.now)
      payments.reverse_order.each do |p|
        balances << {:created_at => p.created_at, :balance => p.quantity}
      end
      if ::Inventory::StockSheet.unscoped.order(created_at: :asc).where(:item => @item).first.created_at < 24.hours.ago
        last_yesterday = ::Inventory::StockSheet.unscoped.order(created_at: :asc).where(:item => @item).where(:created_at => ::Inventory::StockSheet.unscoped.order(created_at: :asc).where(:item => @item).first.created_at..(DateTime.now - 24.hours)).select(:quantity).last
        balances << {:created_at => (DateTime.now - 24.hours), :balance => last_yesterday.quantity}
      end
      @hours = []
      @hourly_balance = {}
      balances.each do |v|
        t = v[:created_at].to_time.change(min: 0, sec: 0, usec: 0)
        # NOTE: Theoretically `unless @hours.include?(t)` is no longer necessary (see 'payments ='; we've already discarded those not needed)
        # For now though, there is a chance that either the ::Inventory::StockSheet.unscoped.order(created_at: :asc).where(:item => @item).first.created_at OR DateTime.now wallet balance will conflict with another value.
        # Leaving it in, though we should definitely look to remove it at some point.
        unless @hours.include?(t)
          unless @hours.empty?
            diff = (((@hours.last - t) / 1.hour) - 1).round
            diff.times do |n|
              time = @hours.last - 1.hour
              @hours << time
              @hourly_balance.merge!(time.in_time_zone(@user.time_zone).strftime("%H:%M") => v[:balance].to_s)
            end
          end
          @hours << t
          unless @hourly_balance[t.in_time_zone(@user.time_zone).strftime("%H:%M")]
            @hourly_balance.merge!(t.in_time_zone(@user.time_zone).strftime("%H:%M") => v[:balance].to_s)
          end
        end
      end
      render json: @hourly_balance.to_a.reverse.to_h
    elsif params[:interval_period] == "daily"
      payments = ::Inventory::StockSheet.unscoped.order(created_at: :asc).where(:item => @item).where(:created_at => ::Inventory::StockSheet.unscoped.order(created_at: :asc).where(:item => @item).select("max(created_at) as created_at").group("date_trunc('day',created_at AT TIME ZONE '#{ActiveSupport::TimeZone.find_tzinfo(@user.time_zone).identifier}')"), :created_at => (DateTime.now - 1.week)..DateTime.now)
      payments.reverse_order.each do |p|
        balances << {:created_at => p.created_at, :balance => p.quantity}
      end
      if ::Inventory::StockSheet.unscoped.order(created_at: :asc).where(:item => @item).first.created_at < 1.week.ago
        last_week = ::Inventory::StockSheet.unscoped.order(created_at: :asc).where(:item => @item).where(:created_at => ::Inventory::StockSheet.unscoped.order(created_at: :asc).where(:item => @item).first.created_at..(DateTime.now - 1.week)).select(:quantity).last
        balances << {:created_at => (DateTime.now - 1.week), :balance => last_week.quantity}
      end
      @days = []
      @daily_balance = {}
      balances.each do |v|
        t = v[:created_at].to_time.in_time_zone(@user.time_zone).change(hour: 0, min: 0, sec: 0, usec: 0)
        unless @days.include?(t)
          unless @days.empty?
            diff = (((@days.last - t) / 1.day) - 1).round
            diff.times do |n|
              time = @days.last - 1.day
              @days << time
              @daily_balance.merge!(time.in_time_zone(@user.time_zone).strftime("%-m/%e") => v[:balance].to_s)
              # @daily_balance.merge!(time.in_time_zone(@user.time_zone).strftime("%A %D") => v[:balance].to_s)
            end
          end
          @days << t
          unless @daily_balance[t.in_time_zone(@user.time_zone).strftime("%-m/%e")]
            @daily_balance.merge!(t.in_time_zone(@user.time_zone).strftime("%-m/%e") => v[:balance].to_s)
          end
          # @daily_balance.merge!(time.in_time_zone(@user.time_zone).strftime("%A %D") => v[:balance].to_s)
        end
      end
      render json: @daily_balance.to_a.reverse.to_h
    elsif params[:interval_period] == "weekly"
      payments = ::Inventory::StockSheet.unscoped.order(created_at: :asc).where(:item => @item).where(:created_at => ::Inventory::StockSheet.unscoped.order(created_at: :asc).where(:item => @item).select("max(created_at) as created_at").group("date_trunc('week',created_at AT TIME ZONE '#{ActiveSupport::TimeZone.find_tzinfo(@user.time_zone).identifier}')"), :created_at => (DateTime.now - 1.month)..DateTime.now)
      # TODO FIXME fuck_it: A one month range is too short, offering only four results. Same applies to daily, only zeven days across a week. Try four (or five) months here and three or four weeks on daily.
      payments.reverse_order.each do |p|
        balances << {:created_at => p.created_at, :balance => p.quantity}
      end
      if ::Inventory::StockSheet.unscoped.order(created_at: :asc).where(:item => @item).first.created_at < 1.month.ago
        last_month = ::Inventory::StockSheet.unscoped.order(created_at: :asc).where(:item => @item).where(:created_at => ::Inventory::StockSheet.unscoped.order(created_at: :asc).where(:item => @item).first.created_at..(DateTime.now - 1.month)).select(:quantity).last
        balances << {:created_at => (DateTime.now - 1.month), :balance => last_month.quantity}
      end
      @weeks = []
      @weekly_balance = {}
      balances.each do |v|
        t = v[:created_at].to_time.in_time_zone(@user.time_zone).change(day: v[:created_at].beginning_of_week(start_day = :monday).strftime("%e").to_i, hour: 0, min: 0, sec: 0, usec: 0)
        unless @weeks.include?(t)
          unless @weeks.empty?
            diff = (((@weeks.last - t) / 1.week) - 1).round
            diff.times do |n|
              time = @weeks.last - 1.week
              @weeks << time
              @weekly_balance.merge!(time.in_time_zone(@user.time_zone).strftime("%-m/%e") => v[:balance].to_s)
            end
          end
          @weeks << t
          unless @weekly_balance[t.in_time_zone(@user.time_zone).strftime("%-m/%e")]
            @weekly_balance.merge!(t.in_time_zone(@user.time_zone).strftime("%-m/%e") => v[:balance].to_s)
          end
        end
      end
      render json: @weekly_balance.to_a.reverse.to_h
    elsif params[:interval_period] == "monthly"
      payments = ::Inventory::StockSheet.unscoped.order(created_at: :asc).where(:item => @item).where(:created_at => ::Inventory::StockSheet.unscoped.order(created_at: :asc).where(:item => @item).select("max(created_at) as created_at").group("date_trunc('month',created_at AT TIME ZONE '#{ActiveSupport::TimeZone.find_tzinfo(@user.time_zone).identifier}')"), :created_at => (DateTime.now - 1.year)..DateTime.now)
      payments.reverse_order.each do |p|
        balances << {:created_at => p.created_at, :balance => p.quantity}
      end
      if ::Inventory::StockSheet.unscoped.order(created_at: :asc).where(:item => @item).first.created_at < 1.year.ago
        last_year = ::Inventory::StockSheet.unscoped.order(created_at: :asc).where(:item => @item).where(:created_at => ::Inventory::StockSheet.unscoped.order(created_at: :asc).where(:item => @item).first.created_at..(DateTime.now - 1.year)).select(:quantity).last
        balances << {:created_at => (DateTime.now - 1.year), :balance => last_year.quantity}
      end
      @months = []
      @monthly_balance = {}
      balances.each do |v|
        t = v[:created_at].to_time.in_time_zone(@user.time_zone).change(day: 1, hour: 0, min: 0, sec: 0, usec: 0)
        unless @months.include?(t)
          unless @months.empty?
            diff = (((@months.last - t) / 1.month) - 1).round
            diff.times do |n|
              time = @months.last - 1.week
              @months << time
              @monthly_balance.merge!(time.in_time_zone(@user.time_zone).strftime("%b") => v[:balance].to_s)
            end
          end
          @months << t
          unless @monthly_balance[t.in_time_zone(@user.time_zone).strftime("%b")]
            @monthly_balance.merge!(t.in_time_zone(@user.time_zone).strftime("%b") => v[:balance].to_s)
          end
        end
      end
      render json: @monthly_balance.to_a.reverse.to_h
    elsif params[:interval_period] == "quarterly"
      # Quarterly conditions go here.
    elsif params[:interval_period] == "yearly"
      # Yearly conditions go here.
    end
  end
end
