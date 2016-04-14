desc "This task is called by the Heroku scheduler add-on"

task :update_exchange_rates_and_currencies => :environment do
  bank = Money.default_bank
  if !bank.rates_updated_at || bank.rates_updated_at < Time.now - 1.days
    $redis.rename("exchange_rates","previous_rates")
    $redis.set("exchange_rates",Money.default_bank.save_rates_to_s)
    # $redis.set("exchange_rates_#{Date.today.to_formatted_s(:db)}",Money.default_bank.save_rates_to_s)
    # Money.default_bank.update_rates_from_s($redis.get("exchange_rates"))

    supported_currencies = []
    Money.default_bank.update_rates_from_s($redis.get("exchange_rates"))
    Money.default_bank.rates.keys.each do |r|
      supported_currencies << r.match(/EUR_TO_([A-Z]+)/).captures.first
    end
    $redis.del("supported_currencies")
    $redis.sadd("supported_currencies",supported_currencies)
    # $redis.sadd("supported_currencies_#{Date.today.to_formatted_s(:db)}",supported_currencies)
    # $redis.smembers("supported_currencies")

    @ancestries = OwnershipAncestry.order(ancestry_depth: :asc).where(:multi_currency => true).where("last_converted < ?", Money.default_bank.rates_updated_at.to_datetime)
    @ancestries.each do |ancestry|
      ancestry.update_conversions
    end
  end
end

task :update_ledgers => :environment do
  adjustment * @ownership.items = Finances::Ledger.where(:fiscal_class => ['long_term','fixed']).where("due_in_full_at < ?", 1.year.from_now)
  adjustment * @ownership.items.each do |ledger|
    ledger.update_fiscal_class
  end
end

task :update_conversions => :environment do
  # Now handled by the update_exchange_rates task AND before updating balance sheets on ownerships.

  #Money.default_bank.update_rates_from_s($redis.get("exchange_rates"))
  #@ancestries = OwnershipAncestry.order(ancestry_depth: :asc).where(:multi_currency => true).where("last_converted < ?", Money.default_bank.rates_updated_at.to_datetime)
  #@ancestries.each do |ancestry|
  #  ancestry.update_conversions
  #end
end