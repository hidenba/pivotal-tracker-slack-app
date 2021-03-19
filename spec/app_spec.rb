require 'webmock/rspec'
require 'json'
require_relative '../src/app'

describe 'app.lambda_handler' do
  let(:event) {
    {
      'body' => {
        kind: 'story_update_activity',
        message: 'Action Message',
        highlight: highlight,
        primary_resources:[
          {
            kind: 'story',
            id: 00000000,
            name: 'Story Name',
            story_type: 'feature',
            url: 'https://www.pivotaltracker.com/story/show/00000000'
          }
        ],
        project: {
          kind: 'project',
          id: 22222222,
          name: 'app'
        },
        performed_by: {
          kind: 'person',
          id:33333333,
          name: 'hidenba',
          initials: 'hidenba'
        },
        occurred_at:1614846617000
      }.to_json
    }
  }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('ID22222222').and_return('https://hooks.slack.com/services/xxxxxx')
    stub_request(:post, ENV['ID22222222']).to_return(body: 'ok')
  end

  subject { lambda_handler event: event, context: nil }

  context '通知対象' do
    let(:ok) {
      {statusCode: 200, body: 'ok'}
    }

    context 'started story' do
      let(:highlight) { 'started' }

      it { is_expected.to eql ok }
    end

    context 'comment story' do
      let(:highlight) { 'added comment:' }

      it { is_expected.to eql ok }
    end
end

  context '通知対象外' do
    let(:skip) {
      {statusCode: 200, body: 'skip'}
    }

    subject { lambda_handler event: event, context: nil }

    context 'edit story' do
      let(:highlight) { 'edited' }

      it { is_expected.to eql skip }
    end

    context 'move story' do
      let(:highlight) { 'moved' }

      it { is_expected.to eql skip }
    end
  end

end
