//
//  FriendsTableViewController.swift
//  Friends
//
//  Created by Jussi Suojanen on 07/11/16.
//  Copyright © 2016 Jimmy. All rights reserved.
//

import UIKit
import PKHUD
import RxSwift
import RxDataSources

public class FriendsTableViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    let viewModel: FriendsTableViewViewModel = FriendsTableViewViewModel()

    private let disposeBag = DisposeBag()

    public override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
        setupCellDeleting()
        setupCellTapHandling()

        viewModel.getFriends()
    }

    func bindViewModel() {
        viewModel.friendCells.asObservable().bind(to: self.tableView.rx.items) { tableView, index, element in
            let indexPath = IndexPath(item: index, section: 0)
            switch element {
            case .normal(let viewModel):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as? FriendTableViewCell else {
                    return UITableViewCell()
                }
                cell.viewModel = viewModel
                return cell
            case .error(let message):
                let cell = UITableViewCell()
                cell.isUserInteractionEnabled = false
                cell.textLabel?.text = message
                return cell
            case .empty:
                let cell = UITableViewCell()
                cell.isUserInteractionEnabled = false
                cell.textLabel?.text = "No data available"
                return cell
            }
        }.disposed(by: disposeBag)

        viewModel.onShowError.asObservable().subscribe(
            onNext: { [weak self] alert in
                if let alert = alert {
                    self?.presentSingleButtonDialog(alert: alert)
                }
            }
        ).disposed(by: disposeBag)

        viewModel.onShowLoadingHud.asObservable().subscribe(
            onNext: { [weak self] visible in
                self?.setLoadingHud(visible: visible)
            },
            onCompleted: { [weak self] in
                self?.setLoadingHud(visible: false)
            }
        ).disposed(by: disposeBag)

    }

    private func setLoadingHud(visible: Bool) {
        PKHUD.sharedHUD.contentView = PKHUDSystemActivityIndicatorView()
        visible ? PKHUD.sharedHUD.show(onView: view) : PKHUD.sharedHUD.hide()
    }

    private func setupCellTapHandling() {
        tableView
            .rx
            .modelSelected(FriendTableViewCellType.self)
            .subscribe(
                onNext: { [weak self] friendCellType in
                    if let selectedRowIndexPath = self?.tableView.indexPathForSelectedRow {
                        self?.tableView?.deselectRow(at: selectedRowIndexPath, animated: true)
                    }
                }
            )
            .disposed(by: disposeBag)
    }

    private func setupCellDeleting() {
        tableView
            .rx
            .modelDeleted(FriendTableViewCellType.self)
            .subscribe(
                onNext: { [weak self] friendCellType in
                    if case let .normal(viewModel) = friendCellType {
                        self?.viewModel.delete(friend: viewModel)
                    }

                    if let selectedRowIndexPath = self?.tableView.indexPathForSelectedRow {
                        self?.tableView?.deselectRow(at: selectedRowIndexPath, animated: true)
                    }
                }
            )
            .disposed(by: disposeBag)
    }

    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "friendsToAddFriend",
            let destinationViewController = segue.destination as? FriendViewController
        {
            destinationViewController.viewModel = AddFriendViewModel()
            destinationViewController.updateFriends.asObserver().subscribe(onNext: { [weak self] () in
                self?.viewModel.getFriends()
                }, onCompleted: {
                    print("ONCOMPLETED")
            }).disposed(by: destinationViewController.disposeBag)
        }

        if segue.identifier == "friendToUpdateFriend",
            let destinationViewController = segue.destination as? FriendViewController,
            let indexPath = tableView.indexPathForSelectedRow
        {
            switch viewModel.friendCells.value[indexPath.row] {
            case .normal(let viewModel):
                destinationViewController.viewModel = UpdateFriendViewModel(friend:viewModel.friendItem)
                destinationViewController.updateFriends.asObserver().subscribe(onNext: { [weak self] () in
                    self?.viewModel.getFriends()
                    }, onCompleted: {
                        print("ONCOMPLETED")
                }).disposed(by: destinationViewController.disposeBag)
            case .empty, .error:
                // nop
                break
            }
        }
    }
}

// MARK: - SingleButtonDialogPresenter
extension FriendsTableViewController: SingleButtonDialogPresenter { }
