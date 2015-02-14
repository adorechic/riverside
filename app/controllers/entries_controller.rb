class EntriesController < UIViewController
  attr_accessor :feeds_controller, :entry

  def viewDidLoad
    super

    rmq.stylesheet = EntriesControllerStylesheet
    init_nav

    rmq.append(UILabel, :entry_title).data(entry["title"])
    webview = rmq.append(UIWebView, :entry_body).get

    html = <<-HTML
    <html>
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    </head>
    <body>
    <h2>#{entry["title"]}</h2>
    #{entry["content"]["content"]}
    </body>
    </html>
    HTML
    webview.loadHTMLString(html, baseURL: nil)

    rmq(self.view).apply_style :root_view
  end

  def init_nav
    self.title = entry["title"]

    self.navigationItem.tap do |nav|
      nav.leftBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(
        UIBarButtonSystemItemReply,
        target: self, action: :nav_left_button
      )
    end

    self.navigationController.setToolbarHidden(false, animated: false)
    spacer = UIBarButtonItem.alloc.initWithBarButtonSystemItem(
      UIBarButtonSystemItemFlexibleSpace,
      target: nil, action: nil
    )

    button = UIBarButtonItem.alloc.initWithBarButtonSystemItem(
      UIBarButtonSystemItemAction,
      target: self,
      action: :open_share_action
    )
    self.toolbarItems = [spacer, button]
  end

  def nav_left_button
    self.dismissViewControllerAnimated(true, completion: nil)
  end

  def open_share_action
    ac = UIAlertController.alertControllerWithTitle(
      "Title",
      message: "Message",
      preferredStyle: UIAlertControllerStyleActionSheet
    )
    act = UIAlertAction.actionWithTitle(
      "Pocket",
      style: UIAlertActionStyleDefault,
      handler: -> (action) {
        pocket_entry
      }
    )
    ac.addAction(act)

    self.presentViewController(ac, animated: true, completion: nil)
  end

  def pocket_entry
    pocket_controller = PocketAuthenticationController.new
    controller = UINavigationController.alloc.initWithRootViewController(
      pocket_controller
    )
    self.presentViewController(controller, animated: true, completion: nil)
  end
end
