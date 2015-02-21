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
    AFMotion::Client.build('https://api.pinboard.in/') {
      response_serializer :xml
    }.get(
      'v1/user/api_token/',
      auth_token: @api_token.text
    ) do |result|
      if result.success?
        parser = result.object
        parser.delegate = self
        parser.parse

        unless @result == @api_token.text.split(':').last
          raise "Invalid"
        end

        pinboard_token = PinboardToken.first || PinboardToken.create
        pinboard_token.auth_token = @api_token.text
        cdq.save
        callback_to_pinboard_controller
      else
        # TODO
        puts result.status_code
        puts result.error.localizedDescription
        puts result.body
      end
    end
  end

  def parser(parser, didStartElement: element_name, namespaceURI: uri, qualifiedName: qname, attributes: attributes)
    if element_name == 'result'
      @target_element = true
    end
  end

  def parser(parser, foundCharacters: string)
    if @target_element
      @result = string
    end
  end

  def parser(parser, didEndElement: element_name, namespaceURI: uri, qualifiedName: qname)
    @target_element = false
  end

  def callback_to_pinboard_controller
    self.dismissViewControllerAnimated(true, completion: nil)
  end
end
