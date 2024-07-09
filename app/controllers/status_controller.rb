class StatusController < ApplicationController
  def email
    # Simple health check for email delivery status
    #
    # Too expensive to compute each time: cache the result
    # if the current time is earlier than 10:15 AM, return nil (emails not yet sent)
    # if the current time is equal to or later than 10:15 AM:
    #   fetch mailgun data if not yet cached
    #   read from cache if it already exists
    # cache is keyed by date
    
    cached_result = nil

    now = Time.now
    today = Time.new(now.year, now.month, now.day, 0, 0, 0)
    ten_fifteen_today = Time.new(now.year, now.month, now.day, 10, 15, 0)

    if now < ten_fifteen_today
      # use cached value from yesterday
      yesterday = today - 1.day
      cached_result = Rails.cache.read("email_status/#{yesterday.asctime()}")
    else
      cached_result = Rails.cache.fetch("email_status/#{today.asctime()}") do
        mg_client = Mailgun::Client.new(ENV.fetch('MAILGUN_API_KEY'))
        mg_events = Mailgun::Events.new(mg_client, ENV.fetch('MAILGUN_DOMAIN'))

        # Mailing List info
        skip = 0
        list_members = []
        ml_result = mg_client.get("lists/peakdemand@mailgun2.mapc.org/members", {'skip' => skip})
        total = ml_result.to_h['total_count']

        loop do
          list_members.push(*ml_result.to_h['items'].map { |member| member['address'] })
          break if list_members.length == total
          skip += 100
          ml_result = mg_client.get("lists/peakdemand@mailgun2.mapc.org/members", {'skip' => skip})
        end

        # Delivery status for today
        total = 0

        successful_recipients = []
        failed_recipients = []
        pending_recipients = []

        events_result = mg_events.get({'begin' => today.to_i, 'end' => now.to_i,
                          'list' => 'peakdemand@mailgun2.mapc.org'})

        loop do
          events_result.to_h['items'].each do | item |
              total += 1
              if item['event'] == 'delivered'
                successful_recipients.push("#{item['recipient']}")
              elsif item['event'] == 'failed' && item['severity'] == 'permanent'
                failed_recipients.push([item['recipient'], item['reason']])
              elsif item['event'] == 'failed' && item['severity'] == 'temporary'
                pending_recipients.push([item['recipient'], item['reason']])
              end
          end
          events_result = mg_events.next
          break if events_result.to_h['items'].length == 0
        end

        successful_percent = ((successful_recipients.length.to_f + pending_recipients.length.to_f) / list_members.length.to_f * 100).to_i
        successful_percent
      end
    end

    if cached_result.nil?
      # There should always be a non-nil result, except for the first time
      # or if the cache gets cleared
      render plain: "OK", status: 200
    elsif cached_result < ENV.fetch('MAILGUN_BAD_DELIVERY_THRESHOLD', 1).to_i
      render plain: "", status: 500
    else
      render plain: "OK", status: 200
    end
  end
end
