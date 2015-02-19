schema "002_create_PocketToken" do
  entity "FeedlyToken" do
    string :access_token, optional: false
    string :refresh_token, optional: false
  end

  entity "PocketToken" do
    string :access_token, optional: false
  end

  entity "PinboardToken" do
    string :auth_token, optional: false
  end
end
