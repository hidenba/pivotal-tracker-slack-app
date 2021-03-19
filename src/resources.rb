class Payload
  attr_reader :body

  def initialize(body)
    @body = JSON.parse(body)
  end

  def event_type
    body['highlight']
  end

  def message
    body['message']
  end

  def comment_body_with_mention
    comment_body.gsub(/@.+?(?=\s|\z)/){ |mention| "<#{mention}>" }
  end

  def message_without_comment_body
    comment_body.empty? ? message : /\A.+(?=: ")/.match(message).to_s
  end

  def comment_body
    /(?<=").+(?=")/m.match(message).to_s
  end

  def notification_target?
    %w(started finished delivered accepted rejected).include?(event_type) || event_type == 'added comment:'
  end

  def person
    Person.new(body['performed_by'])
  end

  def project
    Project.new(body['project'])
  end

  def resources
    body['primary_resources'].map{ |resource| Resource.new(resource) }
  end

  def labels
    return [] unless ENV['TRACKER_TOKEN']

    labels_body = resources.flat_map { |resource|
      res = Faraday.get("https://www.pivotaltracker.com/services/v5/projects/#{project.id}/stories/#{resource.id}") do |res|
        res.headers['X-TrackerToken'] = ENV['TRACKER_TOKEN']
      end
pp res.status
      nil and next if res.status != 200

      JSON.parse(res.body)['labels']
    }.compact

    labels_body.map { |body| Label.new(body) }
  end

  def kind
    body['kind']
  end

  def notification_message
    message_body = {
      blocks: [
        {
          type: :header,
          text: {
            type: :plain_text,
            text: message_without_comment_body,
            emoji: true
          }
        }
      ]
    }

    if !comment_body.empty?
      comment = {
        type: :section,
        text: {
          type: :mrkdwn,
          text: comment_body_with_mention
        }
      }
      message_body[:blocks] << comment
    end

    resources&.each do |resource|
      block = {
        type: :context,
        elements: [{
          type: :mrkdwn,
          text: "#{project.message}: #{resource.message}"
        }]
      }
      message_body[:blocks] << block
    end

    message_body
  end

  def external_announce?
    event_type == 'accepted' && labels.any?(&:announce?)
  end

  def external_announce_message
    message_body = {
      blocks: [
        {
          type: :header,
          text: {
            type: :plain_text,
            text: ":rocket: #{resources.first.name} :rocket:",
            emoji: true
          }
        }
      ]
    }

    resources&.each do |resource|
      block = {
        type: :context,
        elements: [{
          type: :mrkdwn,
          text: resource.url
        }]
      }
      message_body[:blocks] << block
    end

    message_body
  end
end

class Person
  attr_reader :name, :initials, :id

  def initialize(body)
    @name = body['name']
    @id = body['id']
    @initials = body['initials']
  end
end

class Project
  attr_reader :id, :name

  def initialize(body)
    @id = body['id']
    @name = body['name']
  end

  def url
    "https://www.pivotaltracker.com/n/projects/#{id}"
  end

  def message
    "<#{url}|#{name}>"
  end
end

class Resource
  attr_reader :kind, :id, :name

  def initialize(body)
    @kind = body['kind']
    @id = body['id']
    @name = body['name']
    @url = body['url']
  end

  def url
    @url.empty? ? nil : @url
  end

  def message
    url.nil? ? name : "<#{@url}|#{name}>"
  end
end

class Label
  attr_reader :id, :name

  def initialize(body)
    @id = body['id']
    @name = body['name']
  end

  def announce?
    name == 'external-announce'
  end
end
