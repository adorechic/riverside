schema "001_create_FeedlyToken" do
  entity "FeedlyToken" do
    string :access_token, optional: false
    string :refresh_token, optional: false
  end
end
