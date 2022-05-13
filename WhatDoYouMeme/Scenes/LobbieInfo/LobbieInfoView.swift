//
//  LobbieInfoView.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 12.05.2022.
//

import UIKit

final class LobbieInfoView: UIView {
    private unowned let controller: LobbieInfoController


    private let tableView: UITableView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.alwaysBounceVertical = false
        $0.tableFooterView = UIView()
        $0.register(LobbieInfoCell.self, forCellReuseIdentifier: LobbieInfoCell.identifier)
        $0.backgroundColor = .background
        $0.contentInset = UIEdgeInsets(
            top: GlobalConstants.AutoLayout.baseTopInset,
            left: .zero,
            bottom: -GlobalConstants.AutoLayout.baseBottomInset,
            right: .zero
        )
        $0.separatorStyle = UITableViewCell.SeparatorStyle.none
        $0.separatorInset = UIEdgeInsets(
            top: .zero,
            left: GlobalConstants.AutoLayout.baseHorizontalInset,
            bottom: .zero,
            right: GlobalConstants.AutoLayout.baseHorizontalInset
        )
        return $0
    }(UITableView())

    private let readyButton: MemesButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(MemesButton(title: LocalizedString.LobbieInfo.ready.localizedCapitalized, style: .primary))

    private let loader: UIActivityIndicatorView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isHidden = true
        return $0
    }(UIActivityIndicatorView())


    init(controller: LobbieInfoController) {
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
        updateReadyButtonConstraints()
        updateLoaderConstraints()
    }


    func reloadData() {
        tableView.reloadData()
    }

    func setReadyButtonState(_ ready: Bool) {
        readyButton.updateStyle(ready ? .default : .primary)
        let newTitle: String = ready ? LocalizedString.LobbieInfo.notReady : LocalizedString.LobbieInfo.ready
        var words = newTitle.components(separatedBy: " ")
        let capitalizedFirstWord = words[0].capitalized
        words[0] = capitalizedFirstWord
        let finalTitle = words.joined(separator: " ")
        readyButton.setTitle(finalTitle, for: .normal)
    }

    func setLoading(_ enable: Bool) {
        loader.isHidden = !enable
        enable ? loader.startAnimating() : loader.stopAnimating()
    }
}


// MARK: - UITableView Datasource
extension LobbieInfoView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentPlayer = controller.players[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: LobbieInfoCell.identifier, for: indexPath) as! LobbieInfoCell

        var state: LobbieInfoCell.State = .middle
        if controller.players.count == 1 {
            state = .only
        } else if indexPath.row == .zero {
            state = .first
        } else if indexPath.row == controller.players.count - 1 {
            state = .last
        }

        cell.updateData(
            currentPlayer,
            isReady: controller.readyPlayers.contains(where: { $0 == currentPlayer.id }),
            state: state
        )
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controller.players.count
    }
}


// MARK: - Private
private extension LobbieInfoView {
    func setupView() {
        backgroundColor = .background
        setNeedsUpdateConstraints()

        addSubview(tableView)
        addSubview(readyButton)
        addSubview(loader)

        tableView.dataSource = self

        readyButton.addTarget(controller, action: #selector(controller.onReadyButtonTap), for: .touchUpInside)
    }
}


// MARK: - Constraints
private extension LobbieInfoView {
    func updateTableViewConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: readyButton.topAnchor),
            tableView.leftAnchor.constraint(equalTo: leftAnchor),
            tableView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }

    func updateReadyButtonConstraints() {
        NSLayoutConstraint.activate([
            readyButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -GlobalConstants.AutoLayout.baseBottomInset),
            readyButton.leftAnchor.constraint(equalTo: leftAnchor, constant: GlobalConstants.AutoLayout.baseHorizontalInset),
            readyButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -GlobalConstants.AutoLayout.baseHorizontalInset)
        ])
    }

    func updateLoaderConstraints() {
        NSLayoutConstraint.activate([
            loader.topAnchor.constraint(equalTo: topAnchor),
            loader.bottomAnchor.constraint(equalTo: bottomAnchor),
            loader.leftAnchor.constraint(equalTo: leftAnchor),
            loader.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
}
