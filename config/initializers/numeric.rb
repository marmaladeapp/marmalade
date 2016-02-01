class Numeric
  def percent_of(n)
    n / BigDecimal("100") * self
  end

  def convert_currency(first_currency,second_currency)
    if Money.default_bank.rates.empty? || Money.default_bank.last_updated < 1.hour.ago
      Money.default_bank.update_rates_from_s($redis.get("exchange_rates"))
    end
    val1 = Money.new(1000000000000000000000000000,first_currency).to_d
    val2 = Money.new(1000000000000000000000000000,first_currency).exchange_to(second_currency).to_d
    xch = val2 / val1
    self * xch
  end
end
