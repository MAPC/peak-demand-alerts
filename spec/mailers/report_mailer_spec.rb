require 'rails_helper'

RSpec.describe Report, :type => :mailer do
  it "renders the headers" do
    create(:configuration)
    report = create(:report)

    mail = ReportMailer.daily(report)

    expect(mail.subject).to include("Peak Demand Update")
    expect(mail.to).to eq(['peakdemand@mapc.org'])
    expect(mail.from).to eq([ENV.fetch('EMAIL_FROM')])
    expect(mail.bcc).to eq([ENV.fetch('EMAIL_RECIPIENTS')])
  end

  it 'renders the body' do
    pending 'Need to refactor setup steps'
    expect(mail.body.encoded).to include("Hi")
  end
end
