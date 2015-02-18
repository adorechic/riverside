class PinboardAuthenticationController < UIViewController
  def viewDidLoad
    super

    rmq.stylesheet = MainStylesheet
    init_nav
    rmq(self.view).apply_style :root_view
  end

  def init_nav
    self.title = 'Pocket Authentication'
  end
end
