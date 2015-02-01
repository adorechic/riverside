class MainController < UIViewController

  def viewDidLoad
    super

    # Sets a top of 0 to be below the navigation control, it's best not to do this
    # self.edgesForExtendedLayout = UIRectEdgeNone

    rmq.stylesheet = MainStylesheet
    init_nav
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
      client_id: 'feedly',
      client_secret: '0XP4XQ07VVMDWBKUHTJM4WUQ',
      grant_type: 'authorization_code',
      redirect_uri: 'http://www.feedly.com/feedly.html',
      code: code
    ) do |result|
      access_token = result.object["access_token"]

      client = AFMotion::Client.build("https://cloud.feedly.com/") do
        header "Accept", "application/json"
        header "Authorization", "OAuth #{access_token}"
        response_serializer :json
      end

      rmq(self.view).apply_style :root_view

      show_categories = -> (data) {
        @data = data
        puts @data

        @table = UITableView.alloc.initWithFrame(self.view.bounds)
        @table.dataSource = self
        @table.contentInset = [0, 0, 0, 0]

        self.navigationController.navigationBar.translucent = false
        self.view.addSubview @table

      }

      client.get('/v3/markers/counts') do |result|
        categories = result.object["unreadcounts"].select do |item|
          item["id"].start_with?("user/")
        end

        data = categories.map do |item|
          item["name"] = item["id"].split('/').last
          item
        end

        show_categories.call(data)
      end
    end
  end

  def init_nav
    self.title = 'Title Here'

    self.navigationItem.tap do |nav|
      nav.leftBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemAction,
                                                                           target: self, action: :nav_left_button)
      nav.rightBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemRefresh,
                                                                           target: self, action: :nav_right_button)
    end
  end

  def nav_left_button
    puts 'Left button'
  end

  def nav_right_button
    puts 'Right button'
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuseIdentifier ||= "CELL_IDENTIFIER"
    cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier) ||
           TDBadgedCell.alloc.initWithStyle(
             UITableViewCellStyleDefault, reuseIdentifier: @reuseIdentifier
           )

    item = @data[indexPath.row]
    cell.textLabel.text = item["name"]
    count = item["count"]
    if count.to_i == 0
      cell.badgeString = nil
    else
      cell.badgeString = count.to_s
    end

    cell
  end

  def tableView(tableView, numberOfRowsInSection: section)
    @data.count
  end

  # Remove these if you are only supporting portrait
  def supportedInterfaceOrientations
    UIInterfaceOrientationMaskAll
  end
  def willAnimateRotationToInterfaceOrientation(orientation, duration: duration)
    # Called before rotation
    rmq.all.reapply_styles
  end
  def viewWillLayoutSubviews
    # Called anytime the frame changes, including rotation, and when the in-call status bar shows or hides
    #
    # If you need to reapply styles during rotation, do it here instead
    # of willAnimateRotationToInterfaceOrientation, however make sure your styles only apply the layout when
    # called multiple times
  end
  def didRotateFromInterfaceOrientation(from_interface_orientation)
    # Called after rotation
  end
end


__END__

# You don't have to reapply styles to all UIViews, if you want to optimize,
# another way to do it is tag the views you need to restyle in your stylesheet,
# then only reapply the tagged views, like so:
def logo(st)
  st.frame = {t: 10, w: 200, h: 96}
  st.centered = :horizontal
  st.image = image.resource('logo')
  st.tag(:reapply_style)
end

# Then in willAnimateRotationToInterfaceOrientation
rmq(:reapply_style).reapply_styles
