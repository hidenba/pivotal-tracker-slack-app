require 'faraday'
require_relative 'resources'

def lambda_handler(event:, context:)
  payload =Payload.new(event['body'])

  return {statusCode: 200, body: 'skip'} unless payload.notification_target?

  res = Faraday.post(
    ENV["ID#{payload.project.id}"],
    payload.notification_message.to_json,
    "Content-Type" => "application/json"
  )

  {statusCode: res.status, body: res.body}
rescue => e
  puts [e.message, e.backtrace].join("\n")

  {statusCode: 500, body: e.message}
end
