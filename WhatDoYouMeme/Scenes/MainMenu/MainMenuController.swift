//
//  MainMenuController.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 11.05.2022.
//

import UIKit

final class MainMenuController: UIViewController {
    private var mainMenuView: MainMenuView!
    private let interactor: MainMenuInteractor
    private let coordinator: MainMenuCoordinator


    init(interactor: MainMenuInteractor, coordinator: MainMenuCoordinator) {
        self.interactor = interactor
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        mainMenuView = MainMenuView(controller: self)
        view = mainMenuView
        title = LocalizedString.MainMenu.title
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        showCurrentGameIfExists()
    }
}


// MARK: - Actions
extension MainMenuController {
    @objc
    private func onSettingsTap() {
        coordinator.showSettings(fromVC: self)
    }

    @objc
    func onSearchGameTap() {
        coordinator.showLobbiesList(fromVC: self)
    }

    @objc
    func onCreateGameTap() {
        coordinator.showCreateGame(fromVC: self)
    }
}


// MARK: - Private
private extension MainMenuController {
    func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem.settings(
            target: self,
            action: #selector(onSettingsTap)
        )
    }

    func showCurrentGameIfExists() {
        guard let currentGameId = interactor.getCurrentGameId() else { return }
        coordinator.showGameVC(gameId: currentGameId, fromVC: self)
    }
}
