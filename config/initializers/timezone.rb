Timezone::Configure.begin do |c|
  c.username = ENV["GEONAMES_USERNAME"]
  # using geonames.org - LOOKINTO; there may be limits imposed.
end