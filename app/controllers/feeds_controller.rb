class FeedsController < UIViewController
  attr_accessor :category_controller, :category
  def viewDidLoad
    super

    rmq.stylesheet = MainStylesheet
    init_nav


    category_controller.client.get('/v3/streams/contents', streamId: category["id"]) do |result|
      feedly_items = result.object["items"]
      show_entries(feedly_items)
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

  def show_entries(feedly_items)
    @feedly_items = feedly_items

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
           UITableViewCell.alloc.initWithStyle(
             UITableViewCellStyleSubtitle, reuseIdentifier: @reuseIdentifier
           )

    item = @feedly_items[indexPath.row]
    cell.textLabel.text = item["title"]
    cell.textLabel.numberOfLines = 0
    cell.textLabel.font = UIFont.boldSystemFontOfSize(18)
    summary = item["summary"]
    cell.detailTextLabel.text = summary ? summary["content"] : ""
    cell.detailTextLabel.numberOfLines = 1
    cell.detailTextLabel.textColor = UIColor.grayColor
    cell
  end

  def tableView(tableView, numberOfRowsInSection: section)
    @feedly_items.count
  end

  def tableView(tableView, didEndDisplayingCell: cell, forRowAtIndexPath: indexPath)
    puts "Removed #{indexPath.row}"
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    item = @feedly_items[indexPath.row]

    entries_controller = EntriesController.new
    entries_controller.feeds_controller = self
    entries_controller.entry = item
    controller = UINavigationController.alloc.initWithRootViewController(
      entries_controller
    )
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal
    self.presentViewController(controller, animated: true, completion: nil)
  end

end
