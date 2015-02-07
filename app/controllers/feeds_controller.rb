class FeedsController < UIViewController
  attr_accessor :category_controller, :category
  def viewDidLoad
    super

    rmq.stylesheet = MainStylesheet
    init_nav


    category_controller.client.get('/v3/streams/contents', streamId: category["id"]) do |result|
      titles = result.object["items"].map do |entry|
        entry["title"]
      end

      show_entries(titles)
    end

    rmq(self.view).apply_style :root_view
  end

  def init_nav
    self.title = category["name"]

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

  def show_entries(titles)
    @titles = titles

    @table = UITableView.alloc.initWithFrame(self.view.bounds)
    @table.dataSource = self
    @table.contentInset = [0, 0, 0, 0]
    @table.delegate = self

    self.navigationController.navigationBar.translucent = false
    self.view.addSubview @table
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuseIdentifier ||= "CELL_IDENTIFIER"
    cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier) ||
           TDBadgedCell.alloc.initWithStyle(
             UITableViewCellStyleDefault, reuseIdentifier: @reuseIdentifier
           )

    title = @titles[indexPath.row]
    cell.textLabel.text = title
    cell
  end

  def tableView(tableView, numberOfRowsInSection: section)
    @titles.count
  end
end
