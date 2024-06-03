FactoryBot.define do
  factory :forecast do
    date { Date.today }
    high_temp { 87 }
    dew_point { 75 }
    peak_load { 20760 }
    humidity { nil }
    heat_index { nil }
    temperature { nil }
    actual_peak_hour { 19 }
    actual_peak_load { 14886 }
    projection { false }
    peak_hour { DateTime.now }
    report
  end
end
