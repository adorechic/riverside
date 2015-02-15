class FeedlyAuthenticationController < UIViewController
  FEEDLY_CLIENT_ID = ENV['FEEDLY_CLIENT_ID']
  FEEDLY_CLIENT_SECRET = ENV['FEEDLY_CLIENT_SECRET']

  attr_accessor :main_controller

  def viewDidLoad
    super
    rmq.stylesheet = MainStylesheet
    rmq(self.view).apply_style :root_view

    auth_endpoint = 'https://cloud.feedly.com/v3/auth/auth?client_id=feedly&redirect_uri=http://localhost&scope=https://cloud.feedly.com/subscriptions&response_type=code&provider=google&migrate=false'
    @webview = UIWebView.new.tap do |v|
      v.frame = self.view.bounds
      v.scalesPageToFit = true
      v.loadRequest(
        NSURLRequest.requestWithURL(NSURL.URLWithString(auth_endpoint))
      )
      v.delegate = self
      view.addSubview(v)
    end
  end

  def webView(webView, didFailLoadWithError: error)
    url = error.userInfo.objectForKey(NSURLErrorFailingURLStringErrorKey)
    code = url.split("?").last.split("&").map { |pair| pair.split("=") }.detect {|pair| pair.first == "code" }.last

    AFMotion::JSON.post(
      'https://cloud.feedly.com/v3/auth/token',
      client_id: FEEDLY_CLIENT_ID,
      client_secret: FEEDLY_CLIENT_SECRET,
      grant_type: 'authorization_code',
      redirect_uri: 'http://www.feedly.com/feedly.html',
      code: code
    ) do |result|
      feedly_token = FeedlyToken.first
      if feedly_token
        feedly_token.destroy
      end
      FeedlyToken.create(
        access_token: result.object['access_token'],
        refresh_token: result.object['refresh_token']
      )
      cdq.save
      callback_to_main
    end
  end

  def callback_to_main
    main_controller.load_categories
    self.dismissViewControllerAnimated(true, completion: nil)
  end
end
