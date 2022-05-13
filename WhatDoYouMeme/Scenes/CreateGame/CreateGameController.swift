//
//  CreateGameController.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 11.05.2022.
//

import UIKit

final class CreateGameController: UIViewController {
    private var createGameView: CreateGameView!
    private let interactor: CreateGameInteractor
    private let coordinator: CreateGameCoordinator


    private var newLobbieName: String = .empty


    init(interactor: CreateGameInteractor, coordinator: CreateGameCoordinator) {
        self.interactor = interactor
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        createGameView.enableLayoutAnimation(false)
        createGameView.activateNameTextfield()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createGameView.enableLayoutAnimation(true)
    }

    override func onCloseTap() {
        newLobbieName.isEmpty ? super.onCloseTap() : closeAlert()
    }


    func updateLobbieName(_ newName: String) {
        newLobbieName = newName
        createGameView.enableCreateButton(!newName.isEmpty)
    }


    @objc
    func onViewTap() {
        createGameView.hideKeyboard()
    }

    @objc
    func onCreateButtonTap() {
        createGameView.hideKeyboard()
        createGameView.setLoading(true)
        interactor.createLobbie(withName: newLobbieName) { [weak self] lobbie in
            guard let strongSelf = self else { return }
            guard let lobbie = lobbie else {
                strongSelf.showErrorAlert()
                return
            }
            strongSelf.coordinator.showLobbieInfoVC(lobbieId: lobbie.id, fromVC: strongSelf)
        }
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
