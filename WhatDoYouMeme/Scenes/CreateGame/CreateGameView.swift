//
//  CreateGameView.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 11.05.2022.
//

import UIKit

final class CreateGameView: UIView {
    private unowned let controller: CreateGameController


    init(controller: CreateGameController) {
        self.controller = controller
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Private
private extension CreateGameView {
    func setupView() {
        backgroundColor = .background
        setNeedsUpdateConstraints()
    }
}
