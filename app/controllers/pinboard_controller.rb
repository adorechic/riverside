class PinboardController < UIViewController
  def viewDidLoad
    super

    rmq.stylesheet = MainStylesheet
    init_nav
    rmq(self.view).apply_style :root_view

    open_pinboard_authentication_controller
  end

  def init_nav
    self.title = 'Pocket Authentication'
  end

  def open_pinboard_authentication_controller
    pinboard_controller = PinboardAuthenticationController.new
    controller = UINavigationController.alloc.initWithRootViewController(
      pinboard_controller
    )
    self.presentViewController(controller, animated: true, completion: nil)
  end
end
