module Admin
  class EmailsController < Admin::ApplicationController
    def index
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
      now = Time.now
      today = Time.new(now.year, now.month, now.day)

      total = 0
      delivered_count = 0
      failed_count = 0

      failed_recipients = []

      events_result = mg_events.get({'begin' => today.to_i,
                        'list' => 'peakdemand@mailgun2.mapc.org'})

      loop do
        events_result.to_h['items'].each do | item |
            total += 1
            if item['event'] == 'delivered'
              delivered_count += 1
            elsif item['event'] == 'failed'
              failed_count += 1
              failed_recipients.push("#{item['recipient']} - #{item['severity']}, #{item['reason']}")
            end
        end
        events_result = mg_events.next
        break if events_result.to_h['items'].length == 0
      end

      @mailing_details = {
        delivered_count: delivered_count,
        failed_count: failed_count,
        failed_recipients: failed_recipients,
        list_members: list_members,
      }
    end
  end
end
