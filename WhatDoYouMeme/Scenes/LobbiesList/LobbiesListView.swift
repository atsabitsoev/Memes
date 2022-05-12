//
//  LobbiesListView.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 11.05.2022.
//

import UIKit

final class LobbiesListView: UIView {
    private unowned let controller: LobbiesListController


    private let tableView: UITableView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.register(LobbiesListCell.self, forCellReuseIdentifier: LobbiesListCell.identifier)
        $0.tableFooterView = UIView()
        $0.separatorStyle = .none
        $0.backgroundColor = .background
        $0.contentInset = UIEdgeInsets(top: GlobalConstants.AutoLayout.baseTopInset, left: .zero, bottom: .zero, right: .zero)
        return $0
    }(UITableView())


    init(controller: LobbiesListController) {
        self.controller = controller
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        super.updateConstraints()
        updateTableViewConstraints()
    }


    func reloadData() {
        tableView.reloadData()
    }

    func deselectAllRows() {
        tableView.deselectAllRows()
    }
}


// MARK: - Private
private extension LobbiesListView {
    func setupView() {
        backgroundColor = .background
        setNeedsUpdateConstraints()

        addSubview(tableView)
        tableView.delegate = controller
        tableView.dataSource = self
    }
}


// MARK: - Constraints
private extension LobbiesListView {
    func updateTableViewConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: leftAnchor),
            tableView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
}


// MARK: - Table View
extension LobbiesListView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentLobbie = controller.lobbies[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: LobbiesListCell.identifier, for: indexPath) as! LobbiesListCell
        cell.updateData(currentLobbie)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        controller.lobbies.count
    }
}
