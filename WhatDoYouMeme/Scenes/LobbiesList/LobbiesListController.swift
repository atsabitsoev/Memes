//
//  LobbiesListController.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 11.05.2022.
//

import UIKit

final class LobbiesListController: UIViewController {
    private var lobbiesListView: LobbiesListView!
    private let interactor: LobbiesListInteractor
    private let coordinator: LobbiesListCoordinator


    private(set) var lobbies: [Lobbie] = []


    init(interactor: LobbiesListInteractor, coordinator: LobbiesListCoordinator) {
        self.interactor = interactor
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        lobbiesListView = LobbiesListView(controller: self)
        view = lobbiesListView
        title = LocalizedString.LobbiesList.title
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = .empty
        addCloseButton()
        loadLobbies()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lobbiesListView.deselectAllRows()
    }
}


// MARK: - UITableViewDelegate
extension LobbiesListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLobbie = lobbies[indexPath.row]
        coordinator.showLobbieInfoVC(lobbie: selectedLobbie, fromVC: self)
    }
}


// MARK: - Private
private extension LobbiesListController {
    func loadLobbies() {
        interactor.getLobbies { [weak self] lobbies in
            guard let strongSelf = self else { return }
            strongSelf.lobbies = lobbies
            strongSelf.lobbiesListView.reloadData()
        }
    }
}
