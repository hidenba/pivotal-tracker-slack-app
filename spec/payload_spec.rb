require 'json'
require_relative '../src/resources'

describe 'Payload' do
  let(:body) {
      {
        kind: kind,
        message: message,
        highlight: highlight,
        primary_resources:[
          {
            kind: 'story',
            id: 00000000,
            name: 'Story Name',
            story_type: 'feature',
            url: url
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
  let(:kind) { 'story_update_activity' }
  let(:url) { 'https://www.pivotaltracker.com/story/show/00000000' }
  let(:message) { 'Action Message' }

  describe '#notification_target?' do

    subject { payload.notification_target? }

    context 'started' do
      let(:highlight) { 'started' }

      it { is_expected.to be true }
    end

    context 'finished' do
      let(:highlight) { 'finished' }

      it { is_expected.to be true }
    end

    context 'delivered' do
      let(:highlight) { 'delivered' }

      it { is_expected.to be true }
    end

    context 'accepted' do
      let(:highlight) { 'accepted' }

      it { is_expected.to be true }
    end

    context 'rejected' do
      let(:highlight) { 'rejected' }

      it { is_expected.to be true }
    end

    context 'edited' do
      let(:highlight) { 'edited' }

      it { is_expected.to be false }
    end

    context 'blocker create' do
      let(:highlight) { 'created' }
      let(:kind) { 'blocker_create_activity' }

      it { is_expected.to be false }
    end

    context 'task create' do
      let(:highlight) { 'created' }
      let(:kind) { 'task_create_activity' }

      it { is_expected.to be false }
    end

    context 'PR create' do
      let(:highlight) { 'created' }
      let(:kind) { 'pull_request_create_activity' }

      it { is_expected.to be false }
    end
  end

  context 'comment' do
    let(:message) { "hidenba added comment: \"AAAA@alice BBBB@bob CCC@charlie\n @dave\"" }

    describe '#comment_body_with_mention' do
      context 'メンションできる' do
        subject { payload.comment_body_with_mention }

        it { is_expected.to eql "AAAA<@alice> BBBB<@bob> CCC<@charlie>\n <@dave>"}
      end
    end

    describe '#message_without_comment_body' do
      context 'コメント以外を取得できる' do
        subject { payload.message_without_comment_body }

        it { is_expected.to eql "hidenba added comment"}
      end
    end

    describe '#comment_body' do
      context 'コメントを取得できる' do
        subject { payload.comment_body }

        it { is_expected.to eql "AAAA@alice BBBB@bob CCC@charlie\n @dave"}
      end
    end

  end

  describe '#resources' do
    describe '#message' do
      subject { payload.resources.first.message }

      context 'URLがある場合' do
        it { is_expected.to eql '<https://www.pivotaltracker.com/story/show/00000000|Story Name>'}
      end

      context 'URLがない場合' do
        let(:url) { '' }
        it { is_expected.to eql 'Story Name' }
      end
    end
  end

  describe '#notification_message' do
    subject { payload.notification_message }

    context 'コメントなしの場合' do
      let(:message_body) {
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
              type: :context,
              elements: [
                {
                  text: "<https://www.pivotaltracker.com/n/projects/22222222|app>: <https://www.pivotaltracker.com/story/show/00000000|Story Name>",
                  type: :mrkdwn
                }
              ]
            }
          ]
        }
      }
      it { is_expected.to eql message_body }
    end

    context 'コメントありの場合' do
      let(:message) { "hidenba added comment: \"AAAA@alice BBBB@bob CCC@charlie\n @dave\"" }
      let(:message_body) {
        {
          blocks: [
            {
              text: {
                emoji: true,
                text: "hidenba added comment",
                type: :plain_text
              },
              type: :header
            },
            {
              text: {
                text: "AAAA<@alice> BBBB<@bob> CCC<@charlie>\n <@dave>",
                type: :mrkdwn
              },
              type: :section
            },
            {
              type: :context,
              elements: [
                {
                  text: "<https://www.pivotaltracker.com/n/projects/22222222|app>: <https://www.pivotaltracker.com/story/show/00000000|Story Name>",
                  type: :mrkdwn
                }
              ]
            }
          ]
        }
      }

      it { is_expected.to eql message_body}
    end
  end
end
