require 'rails_helper'

RSpec.describe Report, :type => :mailer do
  before(:all) { create(:configuration) }
  let(:mail) { ReportMailer.daily(build(:report)) }

  it "renders the headers" do
    expect(mail.subject).to include("Peak Demand Update")
    expect(mail.to).to eq(['peakdemand@mapc.org'])
    expect(mail.from).to eq([ENV.fetch('EMAIL_FROM')])
    expect(mail.bcc).to eq([ENV.fetch('EMAIL_RECIPIENTS')])
  end

  it 'renders the body' do
    expect(mail.body.encoded).to include("UNLIKELY")
  end
end
