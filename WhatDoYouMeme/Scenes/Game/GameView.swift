//
//  GameView.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 13.05.2022.
//

import UIKit

final class GameView: UIView {
    private let controller: GameController


    init(controller: GameController) {
        self.controller = controller
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Private
private extension GameView {
    func setupView() {
        backgroundColor = .background
        setNeedsUpdateConstraints()
    }
}
