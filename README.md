# UITableView bug with `estimatedRowHeight` and `UITableViewAutomaticDimension`

When using `moveRowAtIndexPath:toIndexPath:` to move a `UITableViewCell`, there
is an animation glitch when using `estimatedRowHeight`, `UITableViewAutomaticDimension`,
and when the cell animates from a visible state to a non-visible state.

To reproduce, make sure `SHOW_BUG` in `TableViewController.m` is defined to `1`. Tap
on `UITableViewCell`s to move them to the top of the list. Note that when the source
and destination index paths for the cell are both visible, everything behaves as expected.

Then, scroll down so that the destination (the top of the table view) is not visible, but
the source (the table view cell that is tapped on) is visible. Note that cells shift around
and the animation is not as it should be.

To compare, define `SHOW_BUG` to `0`. This disables `estimatedRowHeight` 
and `UITableViewAutomaticDimension` and instead 
implements `tableView:heightForRowAtIndexPath:`.

# UITableView bug with `deleteRowsAtIndexPaths`

When using `deleteRowsAtIndexPaths` to delete many rows such that all visible cells will be deleted, 
there is a exception thrown by `UITableView` that it is unable to determine the row rect to aninamate.
`UITableView` will poke delegate for `heightForRowAt` or otherwise throw exception if delegate does not 
provide implementation for `heightForRowAt`.

iOS documentation explains that the data model changes are done before pushing changes onto `UITableView` 
and then the delegate won't have correct data source for `heightForRowAt` to invoke.
