class PocketToken < CDQManagedObject
  POCKET_CONSUMER_KEY = ENV['POCKET_CONSUMER_KEY']

  def self.client
    @client ||= AFMotion::Client.build("https://getpocket.com") do
      request_serializer :json
      response_serializer :json

      header "Content-Type", "application/json; charset=UTF-8"
      header "X-Accept", "application/json"
    end
  end

  def add_entry(args)
    self.class.client.post(
      '/v3/add',
      url: args[:url],
      title: args[:title],
      consumer_key: POCKET_CONSUMER_KEY,
      access_token: access_token
    ) do |result|
      # TODO
      puts result.body
    end
  end
end
