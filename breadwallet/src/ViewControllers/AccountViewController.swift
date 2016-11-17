//
//  AccountViewController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-11-16.
//  Copyright © 2016 breadwallet LLC. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {

    private let store: Store
    private let headerView = AccountHeaderView()
    private let footerView = AccountFooterView()
    private let transactions = TransactionsTableViewController()
    private let headerHeight: CGFloat = 136.0
    private let footerHeight: CGFloat = 56.0

    init(store: Store) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        addTransactionsView()

        view.addSubview(headerView)
        view.addSubview(footerView)
        headerView.constrainTopCorners(sidePadding: 0, topPadding: 0)
        headerView.constrain([
                headerView.constraint(.height, constant: headerHeight)
            ])

        footerView.constrainBottomCorners(sidePadding: 0, bottomPadding: 0)
        footerView.constrain([
                footerView.constraint(.height, constant: footerHeight)
            ])
    }

    func addTransactionsView() {
        addChildViewController(transactions)
        view.addSubview(transactions.view)
        transactions.view.constrain(toSuperviewEdges: nil)
        transactions.tableView.contentInset = UIEdgeInsets(top: headerHeight + Constants.Padding.double, left: 0, bottom: footerHeight + Constants.Padding.double, right: 0)
        transactions.tableView.scrollIndicatorInsets = UIEdgeInsets(top: headerHeight, left: 0, bottom: footerHeight, right: 0)
        transactions.didMove(toParentViewController: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
