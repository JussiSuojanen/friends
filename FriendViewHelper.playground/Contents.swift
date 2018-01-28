import UIKit
import PlaygroundSupport
import TestFriendViewFramework

let bundle = Bundle(for: FriendsTableViewController.self)
let storyboard = UIStoryboard(name: "Main", bundle: bundle)

let friendsTableViewController = storyboard.instantiateInitialViewController()!

PlaygroundPage.current.liveView = friendsTableViewController

