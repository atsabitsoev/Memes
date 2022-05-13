//
//  GameController.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 13.05.2022.
//

import UIKit

final class GameController: UIViewController {
    private var gameView: GameView!


    override func loadView() {
        super.loadView()
        gameView = GameView(controller: self)
        view = gameView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addCloseButton()
    }
}
