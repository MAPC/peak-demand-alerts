FactoryBot.define do
  factory :report do
    current_date { Date.today }

    transient do
      forecasts_count { 5 }
    end

    after(:build) do |report, evaluator|
      create_list(:forecast, evaluator.forecasts_count, report: report)
    end

    after(:build) { |report| report.class.skip_callback(:save, :after, :scrape, raise: false) }
  end
end
