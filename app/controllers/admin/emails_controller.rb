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
      today = Time.new(now.year, now.month, now.day, 0, 0, 0)

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

      # No longer pending if we have a delivered event for this recipient
      pending_recipients = pending_recipients.select{ |record| !successful_recipients.include?(record[0]) }

      # No event found at all for these recipients:
      unexplained_recipients = list_members - failed_recipients.map{ |record| record[0] } - pending_recipients.map{ |record| record[0] } - successful_recipients

      @mailing_details = {
        delivered_count: successful_recipients.length,
        failed_recipients: failed_recipients,
        pending_recipients: pending_recipients,
        unexplained_recipients: unexplained_recipients,
        list_members: list_members,
      }
    end
  end
end
