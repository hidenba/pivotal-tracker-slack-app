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

  def notification_target?
    !(event_type == 'edited' || event_type == 'moved')
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

  def notification_message
    body = {
      blocks: [
        {
          type: :header,
          text: {
            type: :plain_text,
            text: message,
            emoji: true
          }
        }
      ]
    }

    resources&.each do |resource|
      text = "<#{resource.url}|#{resource.name}>"
      block = {
        type: :section,
        text: {
          type: :mrkdwn,
          text: text
        }
      }
      body[:blocks] << block
    end

    body
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
end

class Resource
  attr_reader :kind, :id, :name, :url

  def initialize(body)
    @kind = body['kind']
    @id = body['id']
    @name = body['name']
    @url = body['url']
  end
end
