class PocketAuthenticationController < UIViewController
  attr_accessor :entry

  POCKET_CONSUMER_KEY = ENV['POCKET_CONSUMER_KEY']

  def viewDidLoad
    super

    rmq.stylesheet = MainStylesheet
    init_nav
    rmq(self.view).apply_style :root_view

    PocketToken.client.post(
      'https://getpocket.com/v3/oauth/request',
      consumer_key: POCKET_CONSUMER_KEY,
      redirect_uri: 'http://localhost'
    ) do |result|
      code = result.object["code"]
      open_permit_page(code)
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
    PocketToken.client.post(
      'https://getpocket.com/v3/oauth/authorize',
      consumer_key: POCKET_CONSUMER_KEY,
      code: @code
    ) do |result|
      pocket_token = PocketToken.first || PocketToken.create
      pocket_token.access_token = result.object["access_token"]
      cdq.save
      add_item(entry)
    end
  end

  def add_item(entry)
    PocketToken.first.add_entry(
      url: entry['alternate'].first['href'],
      title: entry['title']
    )
    self.dismissViewControllerAnimated(true, completion: nil)
  end
end
