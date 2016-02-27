class App::Finances::ChartsController < App::AppController

  before_filter :authenticate_user! # Note that this is a temporary solution; we should make use of cancancan and rolify here AND take account for businesses as owners (don't want to restrict by user ownership then)
  # TODO FIXME fuck_it: see above note - currently only ensuring user is logged in

  # TODO fuck_it: we sort of need to adjust chart labels and tooltip format. To do this means setting them manually and taking a shift away from continuous data... I think.
  # Something somewhere is adjusting the dates to show in full no matter what I do with strftime. That's an issue when we're rounding to a previous hour.
  # NOTE fixing this may also mean that you have to reverse order of information again.

  # TODO FIXME fuck_it: REFORMAT - keep it DRY

  # Note: It would be awesome also to date_trunc by half_hour, quarter_hour or other arbitrary but unsupported measure of time
  # See http://stackoverflow.com/questions/12165827/date-trunc-5-minute-interval-in-postgresql for possible solution.
  # It is, however, absolutely possible and supported to do 'minutely' and 'secondly' - how small is too small? Also support for microsecond and millisecond

  # TODO FIXME fuck_it: A certainty is this: You need to do the same for quarterly, yearly...

  # NOTE: Search "Note the repetition of DateTime.now" & "Why not interval_periods as well?"
  # If you could intelligently set something like from_date and to_date and send those across with the request...
  # ...this might solve your repetition problem AND allow for more robust work to be done here too. :)

  def wallet_balance
    @wallet = ::Finances::Wallet.find(params[:wallet_id])
    @user = current_user

    balances = []
    balances << {:created_at => DateTime.now, :balance => @wallet.balance}

    if params[:interval_period] == "minutely"
      payments = @wallet.payments.where(:created_at => @wallet.payments.select("max(created_at) as created_at").group("date_trunc('minute',created_at)"), :created_at => (DateTime.now - 1.hour)..DateTime.now)
      payments.reverse_order.each do |p|
        balances << {:created_at => p.created_at, :balance => p.wallet_balance}
      end
      if @wallet.starting_date < 1.hour.ago
        last_hour = @wallet.payments.where(:created_at => @wallet.starting_date..(DateTime.now - 1.hour)).select(:wallet_balance).last
        if last_hour
          balances << {:created_at => (DateTime.now - 1.hour), :balance => last_hour.wallet_balance}
        else
          balances << {:created_at => @wallet.starting_date, :balance => @wallet.starting_balance}
        end
      else
        balances << {:created_at => @wallet.starting_date, :balance => @wallet.starting_balance}
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
          @minutely_balance.merge!(t.in_time_zone(@user.time_zone).strftime("%H:%M") => v[:balance].to_s)
        end
      end
      render json: @minutely_balance.to_a.reverse.to_h
    elsif params[:interval_period] == "hourly"
      payments = @wallet.payments.where(:created_at => @wallet.payments.select("max(created_at) as created_at").group("date_trunc('hour',created_at)"), :created_at => (DateTime.now - 24.hours)..DateTime.now)
      payments.reverse_order.each do |p|
        balances << {:created_at => p.created_at, :balance => p.wallet_balance}
      end
      if @wallet.starting_date < 24.hours.ago
        last_yesterday = @wallet.payments.where(:created_at => @wallet.starting_date..(DateTime.now - 24.hours)).select(:wallet_balance).last
        if last_yesterday
          balances << {:created_at => (DateTime.now - 24.hours), :balance => last_yesterday.wallet_balance}
        else
          balances << {:created_at => @wallet.starting_date, :balance => @wallet.starting_balance}
        end
        # TODO FIXME fuck_it: Note the repetition of DateTime.now - 24.hours; you don't want to be repeating operations.
        # You absolutely also want to trim down the amount of SQL queries, so should see if there is a way to group everything you need into one.
        # Even if it yields, maybe, more than you would like... that might be a small price compared to querying more than once.
      else
        balances << {:created_at => @wallet.starting_date, :balance => @wallet.starting_balance}
      end
      @hours = []
      @hourly_balance = {}
      balances.each do |v|
        t = v[:created_at].to_time.change(min: 0, sec: 0, usec: 0)
        # NOTE: Theoretically `unless @hours.include?(t)` is no longer necessary (see 'payments ='; we've already discarded those not needed)
        # For now though, there is a chance that either the @wallet.starting_date OR DateTime.now wallet balance will conflict with another value.
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
          @hourly_balance.merge!(t.in_time_zone(@user.time_zone).strftime("%H:%M") => v[:balance].to_s)
        end
      end
      render json: @hourly_balance.to_a.reverse.to_h
    elsif params[:interval_period] == "daily"
      payments = @wallet.payments.where(:created_at => @wallet.payments.select("max(created_at) as created_at").group("date_trunc('day',created_at AT TIME ZONE '#{ActiveSupport::Time_Zone.find_tzinfo(@user.time_zone).identifier}')"), :created_at => (DateTime.now - 1.week)..DateTime.now)
      payments.reverse_order.each do |p|
        balances << {:created_at => p.created_at, :balance => p.wallet_balance}
      end
      if @wallet.starting_date < 1.week.ago
        last_week = @wallet.payments.where(:created_at => @wallet.starting_date..(DateTime.now - 1.week)).select(:wallet_balance).last
        if last_week
          balances << {:created_at => (DateTime.now - 1.week), :balance => last_week.wallet_balance}
        else
          balances << {:created_at => @wallet.starting_date, :balance => @wallet.starting_balance}
        end
      else
        balances << {:created_at => @wallet.starting_date, :balance => @wallet.starting_balance}
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
          @daily_balance.merge!(t.in_time_zone(@user.time_zone).strftime("%-m/%e") => v[:balance].to_s)
          # @daily_balance.merge!(time.in_time_zone(@user.time_zone).strftime("%A %D") => v[:balance].to_s)
        end
      end
      render json: @daily_balance.to_a.reverse.to_h
    elsif params[:interval_period] == "weekly"
      payments = @wallet.payments.where(:created_at => @wallet.payments.select("max(created_at) as created_at").group("date_trunc('week',created_at AT TIME ZONE '#{ActiveSupport::Time_Zone.find_tzinfo(@user.time_zone).identifier}')"), :created_at => (DateTime.now - 1.month)..DateTime.now)
      # TODO FIXME fuck_it: A one month range is too short, offering only four results. Same applies to daily, only zeven days across a week. Try four (or five) months here and three or four weeks on daily.
      payments.reverse_order.each do |p|
        balances << {:created_at => p.created_at, :balance => p.wallet_balance}
      end
      if @wallet.starting_date < 1.month.ago
        last_month = @wallet.payments.where(:created_at => @wallet.starting_date..(DateTime.now - 1.month)).select(:wallet_balance).last
        if last_month
          balances << {:created_at => (DateTime.now - 1.month), :balance => last_month.wallet_balance}
        else
          balances << {:created_at => @wallet.starting_date, :balance => @wallet.starting_balance}
        end
      else
        balances << {:created_at => @wallet.starting_date, :balance => @wallet.starting_balance}
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
          @weekly_balance.merge!(t.in_time_zone(@user.time_zone).strftime("%-m/%e") => v[:balance].to_s)
        end
      end
      render json: @weekly_balance.to_a.reverse.to_h
    elsif params[:interval_period] == "monthly"
      payments = @wallet.payments.where(:created_at => @wallet.payments.select("max(created_at) as created_at").group("date_trunc('month',created_at AT TIME ZONE '#{ActiveSupport::Time_Zone.find_tzinfo(@user.time_zone).identifier}')"), :created_at => (DateTime.now - 1.year)..DateTime.now)
      payments.reverse_order.each do |p|
        balances << {:created_at => p.created_at, :balance => p.wallet_balance}
      end
      if @wallet.starting_date < 1.year.ago
        last_year = @wallet.payments.where(:created_at => @wallet.starting_date..(DateTime.now - 1.year)).select(:wallet_balance).last
        if last_year
          balances << {:created_at => (DateTime.now - 1.year), :balance => last_year.wallet_balance}
        else
          balances << {:created_at => @wallet.starting_date, :balance => @wallet.starting_balance}
        end
      else
        balances << {:created_at => @wallet.starting_date, :balance => @wallet.starting_balance}
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
          @monthly_balance.merge!(t.in_time_zone(@user.time_zone).strftime("%b") => v[:balance].to_s)
        end
      end
      render json: @monthly_balance.to_a.reverse.to_h
    elsif params[:interval_period] == "quarterly"
      # Quarterly conditions go here.
    elsif params[:interval_period] == "yearly"
      # Yearly conditions go here.

      # NOTE: You also need to give consideration to allowing the user to request certain time ranges. Why not interval_periods as well?
      # It wouldn't be too complicated; just a matter of conditionally setting the precision where relevant (hardest at DataBase level perhaps)
      # Definitely possible; absolutely worth considering as an advanced option.
    end
  end

  def resource_balance
    case params[:resource_type]
    when "User"
      @resource = User.find(params[:resource_id])
    when "Business"
      @resource = Business.find(params[:resource_id])
    when "Household"
      @resource = Household.find(params[:resource_id])
    when "Department"
      @resource = Department.find(params[:resource_id])
    when "Room"
      @resource = Room.find(params[:resource_id])
    end
    @user = current_user

    balances = []
    balances << {:created_at => DateTime.now, :balance => @resource.net_worth}

    if params[:interval_period] == "minutely"
      payments = @resource.balance_sheets.where(:created_at => @resource.balance_sheets.select("max(created_at) as created_at").group("date_trunc('minute',created_at)"), :created_at => (DateTime.now - 1.hour)..DateTime.now)
      payments.reverse_order.each do |p|
        balances << {:created_at => p.created_at, :balance => p.net_worth}
      end
      if @resource.balance_sheets.first.created_at < 1.hour.ago
        last_hour = @resource.balance_sheets.where(:created_at => @resource.balance_sheets.first.created_at..(DateTime.now - 1.hour)).select(:net_worth).last
        balances << {:created_at => (DateTime.now - 1.hour), :balance => last_hour.net_worth}
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
              @minutely_balance.merge!(time.in_time_zone(@user.time_zone).strftime("%c") => v[:balance].to_s)
            end
          end
          @minutes << t
          @minutely_balance.merge!(t.in_time_zone(@user.time_zone).strftime("%c") => v[:balance].to_s)
        end
      end
      render json: @minutely_balance.to_a.reverse.to_h
    elsif params[:interval_period] == "hourly"
      payments = @resource.balance_sheets.where(:created_at => @resource.balance_sheets.select("max(created_at) as created_at").group("date_trunc('hour',created_at)"), :created_at => (DateTime.now - 24.hours)..DateTime.now)
      payments.reverse_order.each do |p|
        balances << {:created_at => p.created_at, :balance => p.net_worth}
      end
      if @resource.balance_sheets.first.created_at < 24.hours.ago
        last_yesterday = @resource.balance_sheets.where(:created_at => @resource.balance_sheets.first.created_at..(DateTime.now - 24.hours)).select(:net_worth).last
        balances << {:created_at => (DateTime.now - 24.hours), :balance => last_yesterday.net_worth}
      end
      @hours = []
      @hourly_balance = {}
      balances.each do |v|
        t = v[:created_at].to_time.change(min: 0, sec: 0, usec: 0)
        # NOTE: Theoretically `unless @hours.include?(t)` is no longer necessary (see 'payments ='; we've already discarded those not needed)
        # For now though, there is a chance that either the @resource.balance_sheets.first.created_at OR DateTime.now wallet balance will conflict with another value.
        # Leaving it in, though we should definitely look to remove it at some point.
        unless @hours.include?(t)
          unless @hours.empty?
            diff = (((@hours.last - t) / 1.hour) - 1).round
            diff.times do |n|
              time = @hours.last - 1.hour
              @hours << time
              @hourly_balance.merge!(time.in_time_zone(@user.time_zone).strftime("%c") => v[:balance].to_s)
            end
          end
          @hours << t
          @hourly_balance.merge!(t.in_time_zone(@user.time_zone).strftime("%c") => v[:balance].to_s)
        end
      end
      render json: @hourly_balance.to_a.reverse.to_h
    elsif params[:interval_period] == "daily"
      payments = @resource.balance_sheets.where(:created_at => @resource.balance_sheets.select("max(created_at) as created_at").group("date_trunc('day',created_at AT TIME ZONE '#{ActiveSupport::Time_Zone.find_tzinfo(@user.time_zone).identifier}')"), :created_at => (DateTime.now - 1.week)..DateTime.now)
      payments.reverse_order.each do |p|
        balances << {:created_at => p.created_at, :balance => p.net_worth}
      end
      if @resource.balance_sheets.first.created_at < 1.week.ago
        last_week = @resource.balance_sheets.where(:created_at => @resource.balance_sheets.first.created_at..(DateTime.now - 1.week)).select(:net_worth).last
        balances << {:created_at => (DateTime.now - 1.week), :balance => last_week.net_worth}
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
              @daily_balance.merge!(time.in_time_zone(@user.time_zone).strftime("%c") => v[:balance].to_s)
              # @daily_balance.merge!(time.in_time_zone(@user.time_zone).strftime("%A %D") => v[:balance].to_s)
            end
          end
          @days << t
          @daily_balance.merge!(t.in_time_zone(@user.time_zone).strftime("%c") => v[:balance].to_s)
          # @daily_balance.merge!(time.in_time_zone(@user.time_zone).strftime("%A %D") => v[:balance].to_s)
        end
      end
      render json: @daily_balance.to_a.reverse.to_h
    elsif params[:interval_period] == "weekly"
      payments = @resource.balance_sheets.where(:created_at => @resource.balance_sheets.select("max(created_at) as created_at").group("date_trunc('week',created_at AT TIME ZONE '#{ActiveSupport::Time_Zone.find_tzinfo(@user.time_zone).identifier}')"), :created_at => (DateTime.now - 1.month)..DateTime.now)
      # TODO FIXME fuck_it: A one month range is too short, offering only four results. Same applies to daily, only zeven days across a week. Try four (or five) months here and three or four weeks on daily.
      payments.reverse_order.each do |p|
        balances << {:created_at => p.created_at, :balance => p.net_worth}
      end
      if @resource.balance_sheets.first.created_at < 1.month.ago
        last_month = @resource.balance_sheets.where(:created_at => @resource.balance_sheets.first.created_at..(DateTime.now - 1.month)).select(:net_worth).last
        balances << {:created_at => (DateTime.now - 1.month), :balance => last_month.net_worth}
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
              @weekly_balance.merge!(time.in_time_zone(@user.time_zone).strftime("%c") => v[:balance].to_s)
            end
          end
          @weeks << t
          @weekly_balance.merge!(t.in_time_zone(@user.time_zone).strftime("%c") => v[:balance].to_s)
        end
      end
      render json: @weekly_balance.to_a.reverse.to_h
    elsif params[:interval_period] == "monthly"
      payments = @resource.balance_sheets.where(:created_at => @resource.balance_sheets.select("max(created_at) as created_at").group("date_trunc('month',created_at AT TIME ZONE '#{ActiveSupport::Time_Zone.find_tzinfo(@user.time_zone).identifier}')"), :created_at => (DateTime.now - 1.year)..DateTime.now)
      payments.reverse_order.each do |p|
        balances << {:created_at => p.created_at, :balance => p.net_worth}
      end
      if @resource.balance_sheets.first.created_at < 1.year.ago
        last_year = @resource.balance_sheets.where(:created_at => @resource.balance_sheets.first.created_at..(DateTime.now - 1.year)).select(:net_worth).last
        balances << {:created_at => (DateTime.now - 1.year), :balance => last_year.net_worth}
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
              @monthly_balance.merge!(time.in_time_zone(@user.time_zone).strftime("%c") => v[:balance].to_s)
            end
          end
          @months << t
          @monthly_balance.merge!(t.in_time_zone(@user.time_zone).strftime("%c") => v[:balance].to_s)
        end
      end
      render json: @monthly_balance.to_a.reverse.to_h
    elsif params[:interval_period] == "quarterly"
      # Quarterly conditions go here.
    elsif params[:interval_period] == "yearly"
      # Yearly conditions go here.

      # NOTE: You also need to give consideration to allowing the user to request certain time ranges. Why not interval_periods as well?
      # It wouldn't be too complicated; just a matter of conditionally setting the precision where relevant (hardest at DataBase level perhaps)
      # Definitely possible; absolutely worth considering as an advanced option.
    end
  end
end


# TODO FIXME fuck_it: IMPORTANT! There is far too much repetition above: you only need to convert to the user time_zone once... Last.
# Any other functions using the time object will just manipulate it again. This does make for an interesting problem where you'd like
# to show two time_zones on a chart... but cross that bridge later. Remove all repetition first, fix for all the broken nonsense and then
# worry about additional work.
