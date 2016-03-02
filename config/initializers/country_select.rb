CountrySelect::FORMATS[:with_country_code] = lambda do |country|
  "#{country.name} (+#{country.country_code})"
end