require 'json'
require_relative '../src/resources'

describe 'Payload' do
  let(:body) {
      {
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
  let(:highlight) { 'created' }
  let(:payload) { Payload.new(body) }

  describe '#notification_target?' do

    subject { payload.notification_target? }

    context 'created' do
      it { is_expected.to be true }
    end

    context 'moved' do
      let(:highlight) { 'moved' }

      it { is_expected.to be false }
    end

    context 'edited' do
      let(:highlight) { 'edited' }

      it { is_expected.to be false }
    end
  end


  describe '#notification_message' do
    let(:message) {
      {
        blocks: [
          {
            text: {
              emoji: true,
              text: "Action Message",
              type: :plain_text
            },
            type: :header
          },
          {
            text: {
              text: "<https://www.pivotaltracker.com/story/show/00000000|Story Name>",
              type: :mrkdwn
            },
            type: :section
          }
        ]
      }
    }
    subject { payload.notification_message }

    it { is_expected.to eql message }
  end
end