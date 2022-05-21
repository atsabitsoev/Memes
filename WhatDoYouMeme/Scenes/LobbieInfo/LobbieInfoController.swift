//
//  LobbieInfoController.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 12.05.2022.
//

import UIKit

final class LobbieInfoController: UIViewController {
    private var lobbieInfoView: LobbieInfoView!
    private let interactor: LobbieInfoInteractor
    private let coordinator: LobbieInfoCoordinator


    private let lobbieId: String
    private var lobbie: Lobbie?


    var players: [Player] = []
    var readyPlayers: [String] = []


    init(interactor: LobbieInfoInteractor, coordinator: LobbieInfoCoordinator, lobbieId: String) {
        self.interactor = interactor
        self.lobbieId = lobbieId
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        lobbieInfoView = LobbieInfoView(controller: self)
        view = lobbieInfoView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addCloseButton()
        enterInLobbie { [weak self] in
            self?.loadLobbie()
        }
    }

    override func onCloseTap() {
        closeAlert()
    }

    
    @objc
    func onReadyButtonTap() {
        lobbieInfoView.setLoading(true)
        interactor.toggleReady(lobbieId: lobbieId) { [weak self] in
            self?.lobbieInfoView.setLoading(false)
        }
    }
}


// MARK: - Private
private extension LobbieInfoController {

    func loadLobbie() {
        lobbieInfoView.setLoading(true)
        interactor.loadLobbie(byId: lobbieId) { [weak self] lobbie in
            guard let strongSelf = self, let lobbie = lobbie else {
                self?.lobbieInfoView.setLoading(false)
                self?.dismiss(animated: true)
                return
            }
            self?.lobbie = lobbie
            strongSelf.title = lobbie.name
            if let gameId = lobbie.gameId {
                strongSelf.coordinator.showGameVC(gameId: gameId, from: strongSelf)
            } else if lobbie.membersPaths.count > 1 && Set(lobbie.readyMembersPaths) == Set(lobbie.membersPaths) {
                strongSelf.createGame {
                    print("игра создана")
                }
            }

            strongSelf.interactor.loadPlayers(withPaths: lobbie.membersPaths) { [weak self] players in
                guard let strongSelf = self else {
                    strongSelf.lobbieInfoView.setLoading(false)
                    return
                }
                strongSelf.players = players
                strongSelf.readyPlayers = lobbie.readyMembersPaths.compactMap({ $0.components(separatedBy: "/").last })
                if let userId = strongSelf.interactor.getUserId() {
                    let curerntUserIsReady = lobbie.readyMembersPaths.compactMap({ $0.components(separatedBy: "/").last }).contains(userId)
                    strongSelf.lobbieInfoView.setReadyButtonState(curerntUserIsReady)
                }
                strongSelf.lobbieInfoView.reloadData()
                strongSelf.lobbieInfoView.setLoading(false)
            }
        }
    }

    func createGame(_ handler: @escaping () -> Void) {
        interactor.createGame(lobbieId: lobbieId, handler)
    }

    func enterInLobbie(_ handler: @escaping () -> Void) {
        lobbieInfoView.setLoading(true)
        interactor.enterInLobbie(lobbieId: lobbieId) { [weak self] in
            self?.lobbieInfoView.setLoading(false)
            handler()
        }
    }

    func quitFromLobbie(_ handler: (() -> Void)? = nil) {
        lobbieInfoView.setLoading(true)
        interactor.quitFromLobbie { [weak self] in
            handler?()
            self?.lobbieInfoView.setLoading(false)
        }
    }

    func closeAlert() {
        let alert = UIAlertController(
            title: nil,
            message: LocalizedString.LobbieInfo.closeAlertMessage,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(
            title: LocalizedString.LobbieInfo.closeAlertOkAction,
            style: .default) { [weak self] _ in
                self?.quitFromLobbie {
                    self?.dismiss(animated: true)
                }
            }
        let cancelAction = UIAlertAction(
            title: LocalizedString.LobbieInfo.closeAlertCancelAction,
            style: .cancel
        )
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
}
