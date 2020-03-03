# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Configuration.create! possible_min: 22_500, possible_max: 23_500

begin
  Report.create!
rescue KeyError => e
  puts 'e.message'
  puts 'Please ensure your environment vars contain ISO_USER and ISO_PASS.'
end
