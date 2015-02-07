class FeedsController < UIViewController
  attr_accessor :category_controller, :category_name
  def viewDidLoad
    super

    rmq.stylesheet = MainStylesheet
    init_nav

    rmq(self.view).apply_style :root_view
  end

  def init_nav
    self.title = category_name

    self.navigationItem.tap do |nav|
      nav.leftBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(
        UIBarButtonSystemItemReply,
        target: self, action: :nav_left_button
      )
    end
  end

  def nav_left_button
    self.dismissViewControllerAnimated(true, completion: nil)
  end
end
