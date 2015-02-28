class MainController < UIViewController
  def viewDidLoad
    super

    # Sets a top of 0 to be below the navigation control, it's best not to do this
    # self.edgesForExtendedLayout = UIRectEdgeNone

    rmq.stylesheet = MainStylesheet
    init_nav
    rmq(self.view).apply_style :root_view

    feedly_token = FeedlyToken.first
    if feedly_token
      load_categories
    else
      auth_controller = FeedlyAuthenticationController.new
      auth_controller.main_controller = self
      controller = UINavigationController.alloc.initWithRootViewController(
        auth_controller
      )
      self.presentViewController(controller, animated: true, completion: nil)
    end
  end

  def client
    token = FeedlyToken.first.access_token
    @client ||= AFMotion::Client.build("https://cloud.feedly.com/") do
      header "Accept", "application/json"
      header "Authorization", "OAuth #{token}"
      response_serializer :json
    end
  end

  def load_categories
    rmq(self.view).apply_style :root_view

    client.get('/v3/markers/counts') do |result|
      categories = result.object["unreadcounts"].select do |item|
        item["id"].start_with?("user/")
      end

      data = categories.map do |item|
        item["name"] = item["id"].split('/').last
        item
      end

      show_categories(data)
    end
  end

  def show_categories(data)
    @data = data.select {|item| item["count"].to_i > 0 }

    @table = UITableView.alloc.initWithFrame(self.view.bounds)
    @table.dataSource = self
    @table.contentInset = [0, 0, 0, 0]
    @table.delegate = self

    self.navigationController.navigationBar.translucent = false
    self.view.addSubview @table
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

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    item = @data[indexPath.row]

    feeds_controller = FeedsController.new
    feeds_controller.category_controller = self
    feeds_controller.category = item
    controller = UINavigationController.alloc.initWithRootViewController(
      feeds_controller
    )
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal
    self.presentViewController(controller, animated: true, completion: nil)
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
