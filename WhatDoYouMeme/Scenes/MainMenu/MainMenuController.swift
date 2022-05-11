//
//  MainMenuController.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 11.05.2022.
//

import UIKit

final class MainMenuController: UIViewController {
    private var mainMenuView: MainMenuView!
    private let coordinator = MainMenuCoordinator()


    override func loadView() {
        super.loadView()
        mainMenuView = MainMenuView(controller: self)
        view = mainMenuView
        title = LocalizedString.MainMenu.title
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
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
}
