//
//  GameController.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 13.05.2022.
//

import UIKit

final class GameController: UIViewController {
    private var gameView: GameView!


    private let gameId: String
    private var game: Game! {
        didSet {
            onGameUpdate(game)
        }
    }


    init(gameId: String) {
        self.gameId = gameId
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
}


private extension GameController {
    func loadGame() {
        let newGame = Game(
            players: [
                Game.Player(
                    hand: [
                        "https://c.wallhere.com/photos/fc/9a/1366x768_px_Canada_landscape_mountain_stars_Trees-1080526.jpg!d",
                        "https://c.wallhere.com/photos/22/27/2560x1600_px_landscape_nature-1077192.jpg!d"
                    ],
                    isOnline: true,
                    playerRef: "players/wZm1cqFIC8FXxA3ESU8R"
                ),
                Game.Player(
                    hand: [
                        "https://verol.net/images/virtuemart/product/PP00068V.jpg",
                        "https://divino-d.com/uploads/product/31900/31999/619ec4d6bd7711e7a22f1866da87aa23_69f3d2ce3dde11eaa2c11866da87aa23.jpg"
                    ],
                    isOnline: true,
                    playerRef: "players/shHWww4L7HXxgYZPLvgH"
                )
            ],
            situations: [
                "Когда обосрался на глазах у родителей жены",
                "Когда друг не возвращает деньги, но ездит на такси комфорт класса",
                "Когда надел батин пиджак и нашел во внутреннем кармане презерватив"
            ],
            currentStep: Game.Step(index: 0)
        )
        game = newGame
    }

    func onGameUpdate(_ game: Game) {
        gameView.setGame(game)
    }
}
