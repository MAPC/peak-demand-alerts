# frozen_string_literal: true

module Admin
  class PeaksController < Admin::ApplicationController
    before_action :validate_params, only: [:create]
    def index
      prep_form()
    end

    def create
      recipient = ""
      if params[:recipients] == "internal"
        recipient = "#{params[:mapc_recipient]}@mapc.org"
      elsif params[:recipients] == "list"
        recipient = ENV.fetch('MAILGUN_MAILING_LIST', 'staging@mailgun2.mapc.org')
      end
      mg_client = Mailgun::Client.new(ENV.fetch('MAILGUN_API_KEY'))
      mb_obj = Mailgun::MessageBuilder.new

      mb_obj.from(ENV.fetch('EMAIL_FROM', 'Peak Load via MAPC <peakdemand@mapc.org>'))
      mb_obj.add_recipient("to", recipient)
      mb_obj.subject ("MAPC Peak Demand Notification: Likely Peak #{params[:day_of_week_capitalized]} - Recommended Actions")
      mb_obj.template('likely peak alert')
      mb_obj.template_version('with-variables')
      params.each do |k, v|
        mb_obj.variable(k, v)
      end

      result = mg_client.send_message(ENV.fetch('MAILGUN_DOMAIN'), mb_obj).to_h!
      message_id = result['id']
      message = result['message']

      # Not great
      success = message == "Queued. Thank you."

      # flash[:notice] = "(TEST) Successfully sent email"
      render json: { success: success }
    end

    private
    def validate_params
      return false if params[:peak_start_hour].nil? || params[:peak_end_hour].nil? || params[:peak_value_gw].nil? || params[:day_of_week].nil? || params[:day_of_week_capitalized].nil? || params[:action_start_hour].nil? || params[:action_end_hour].nil? || params[:recipients].nil? || params[:mapc_recipients].nil?
      return false if params[:peak_start_hour] == "" || params[:peak_end_hour] == "" || params[:peak_value_gw] == "" || params[:day_of_week] == "" || params[:day_of_week_capitalized] == "" || params[:action_start_hour] == "" || params[:action_end_hour] == "" || params[:recipients] == "" || (params[:recipients] == "internal" && params[:mapc_recipients] == "") || params[:recipients] == "nobody"
    end

    def prep_form
      mg_client = Mailgun::Client.new(ENV.fetch('MAILGUN_API_KEY'))

      ml_result = mg_client.get("lists/peakdemand@mailgun2.mapc.org/members", {'skip' => 0})
      total = ml_result.to_h['total_count']

      result = mg_client.get("#{ENV.fetch('MAILGUN_DOMAIN')}/templates/likely%20peak%20alert", {:active => true})
      resp = result.to_h
      templ_body = Base64.encode64(resp["template"]["version"]["template"])
      
      @mailing_details = {
        list_address: "peakdemand@mailgun2.mapc.org",
        list_count: total,
        template_body: templ_body
      }

    end
  end
end
