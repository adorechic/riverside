class PinboardController < UIViewController
  attr_accessor :entry

  def viewDidLoad
    super

    rmq.stylesheet = PinboardControllerStylesheet
    init_nav
    rmq(self.view).apply_style :root_view

    if PinboardToken.first
      add_pinboard_form
    else
      open_pinboard_authentication_controller
    end
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

  def add_pinboard_form
    @url = rmq.append(UITextField, :url).get
    @url.delegate = self
    @url.text = entry['alternate'].first['href']

    @title = rmq.append(UITextField, :title).get
    @title.delegate = self
    @title.text = entry['title']

    @tag = rmq.append(UITextField, :tag).get
    @tag.delegate = self

    rmq.append(UIButton, :submit_button).on(:touch) do |sender|
      add_pinboard
    end
  end

  def add_pinboard
    puts "Add!"
  end
end
