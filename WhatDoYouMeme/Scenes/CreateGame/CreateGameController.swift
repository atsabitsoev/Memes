//
//  CreateGameController.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 11.05.2022.
//

import UIKit

final class CreateGameController: UIViewController {
    private var createGameView: CreateGameView!


    override func loadView() {
        super.loadView()
        createGameView = CreateGameView(controller: self)
        view = createGameView
        title = LocalizedString.CreateGame.title
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addCloseButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createGameView.activateNameTextfield()
    }

    override func onCloseTap() {
        closeAlert()
    }


    @objc
    func onViewTap() {
        createGameView.hideKeyboard()
    }
}


// MARK: - Private
private extension CreateGameController {
    func closeAlert() {
        let alert = UIAlertController(
            title: LocalizedString.CreateGame.closeAlertTitle,
            message: LocalizedString.CreateGame.closeAlertMessage,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(
            title: LocalizedString.CreateGame.closeAlertOkAction,
            style: .default) { _ in super.onCloseTap() }
        let cancelAction = UIAlertAction(
            title: LocalizedString.CreateGame.closeAlertCancelAction,
            style: .cancel
        )
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
}
