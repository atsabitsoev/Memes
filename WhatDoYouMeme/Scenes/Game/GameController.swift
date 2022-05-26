//
//  GameController.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 13.05.2022.
//

import UIKit

final class GameController: UIViewController {
    private var gameView: GameView!
    private let interactor: GameInteractor
    private let coordinator: GameCoordinator


    private let gameId: String
    private var game: Game? {
        didSet {
            guard let game = game else { return }
            onGameUpdate(game)
        }
    }


    init(
        interactor: GameInteractor,
        coordinator: GameCoordinator,
        gameId: String
    ) {
        self.gameId = gameId
        self.interactor = interactor
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        gameView = GameView(controller: self)
        view = gameView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addCloseButton()
        loadGame()
    }

    override func onCloseTap() {
        closeAlert()
    }
}


// MARK: - Private
private extension GameController {
    func loadGame() {
        interactor.loadGame(withId: gameId) { [weak self] game in
            guard let strongSelf = self,
                  let game = game else {
                self?.dismiss(animated: true)
                return
            }
            if let oldGame = strongSelf.game, oldGame.currentStep.index < game.currentStep.index {
                strongSelf.showStepResults(
                    steppedPlayers: game.currentStep.steppedPlayers,
                    situation: oldGame.situations[oldGame.currentStep.index]
                )
            }
            strongSelf.game = game
        }
    }

    func onGameUpdate(_ game: Game) {
        gameView.setGame(game)
        gameView.setOnCardConfigmedHandler { [weak self] selectedCard in
            self?.makeStep(card: selectedCard)
        }
    }

    func quitFromGame(_ handler: @escaping (Bool) -> Void) {
        interactor.quitGame(withId: gameId, handler)
    }

    func makeStep(card: String) {
        interactor.makeStep(gameId: gameId, card: card, handler: nil)
    }

    func showStepResults(
        steppedPlayers: [Game.Step.SteppedPlayer],
        situation: String
    ) {
        coordinator.showStepResultsVC(
            situation: situation,
            steppedPlayers: steppedPlayers,
            fromVC: self
        )
    }

    func closeAlert() {
        let alert = UIAlertController(
            title: nil,
            message: LocalizedString.Game.closeAlertMessage,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(
            title: LocalizedString.Game.closeAlertOkAction,
            style: .default) { [weak self] _ in
                self?.quitFromGame { success in
                    guard success else { return }
                    self?.dismiss(animated: true)
                }
            }
        let cancelAction = UIAlertAction(
            title: LocalizedString.Game.closeAlertCancelAction,
            style: .cancel
        )
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
}
