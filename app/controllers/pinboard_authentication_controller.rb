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
    AFMotion::JSON.get(
      'https://api.pinboard.in/v1/user/api_token/',
      format: 'json',
      auth_token: @api_token.text
    ) do |result|
      if result.success?
        pinboard_token = PinboardToken.first || PinboardToken.create
        pinboard_token.auth_token = result.object["result"]
        cdq.save
        callback_to_pinboard_controller
      end
    end
  end

  def callback_to_pinboard_controller
    self.dismissViewControllerAnimated(true, completion: nil)
  end
end
