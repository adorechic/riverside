class PinboardAuthenticationController < UIViewController
  def viewDidLoad
    super

    rmq.stylesheet = PinboardAuthenticationControllerStylesheet
    init_nav
    rmq(self.view).apply_style :root_view

    @api_token = rmq.append(UITextField, :api_token_field).get
    @api_token.delegate = self

    rmq.append(UIButton, :submit_button).on(:touch) do |sender|
      authenticate
    end
  end

  def init_nav
    self.title = 'Pocket Authentication'
  end

  def authenticate
    puts "Authenticate!"
  end
end
