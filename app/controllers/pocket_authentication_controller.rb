class PocketAuthenticationController < UIViewController
  POCKET_CONSUMER_KEY = ENV['POCKET_CONSUMER_KEY']

  def viewDidLoad
    super

    rmq.stylesheet = MainStylesheet
    init_nav
    rmq(self.view).apply_style :root_view

    client.post(
      'https://getpocket.com/v3/oauth/request',
      consumer_key: POCKET_CONSUMER_KEY,
      redirect_uri: 'http://localhost'
    ) do |result|
      code = result.body.split("=").last
      open_permit_page(code)
    end
  end

  def client
    @client ||= AFMotion::Client.build("https://getpocket.com") do
      request_serializer :json
      response_serializer :form
    end
  end

  def open_permit_page(code)
    @code = code
    authorize_url = "https://getpocket.com/auth/authorize?request_token=#{code}&redirect_uri=http://localhost"
    @webview = UIWebView.new.tap do |v|
      v.frame = self.view.bounds
      v.scalesPageToFit = true
      v.loadRequest(
        NSURLRequest.requestWithURL(NSURL.URLWithString(authorize_url))
      )
      v.delegate = self
      view.addSubview(v)
    end
  end

  def init_nav
    self.title = 'Pocket Authentication'
  end

  def webView(webView, didFailLoadWithError: error)
    client.post(
      'https://getpocket.com/v3/oauth/authorize',
      consumer_key: POCKET_CONSUMER_KEY,
      code: @code
    ) do |result|
      access_token = result.body.split("&").
        map { |kv| kv.split("=") }.
        detect { |kv| kv.first == "access_token" }.last

      puts "!!!! GET ACCESS TOKEN !!!!!"
      puts access_token
    end
  end
end
