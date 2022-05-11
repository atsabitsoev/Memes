//
//  MainMenuView.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 11.05.2022.
//

import UIKit

final class MainMenuView: UIView {
    enum Constants {
        static let buttonsStackCenterYOffset: CGFloat = -80
        static let buttonsStackSpacing: CGFloat = 16
    }


    private unowned let controller: MainMenuController


    private let buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = NSLayoutConstraint.Axis.vertical
        stack.spacing = Constants.buttonsStackSpacing
        return stack
    }()
    private let searchGameButton = MemesButton(
        title: LocalizedString.MainMenu.searchGame,
        style: .primary
    )
    private let createGameButton = MemesButton(
        title: LocalizedString.MainMenu.createGame,
        style: .default
    )
    
    
    init(controller: MainMenuController) {
        self.controller = controller
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        super.updateConstraints()
        updateButtonsStackConstraints()
    }
}


// MARK: - Private
private extension MainMenuView {
    func setupView() {
        backgroundColor = .background
        setNeedsUpdateConstraints()

        buttonsStack.addArrangedSubviews(searchGameButton, createGameButton)
        addSubview(buttonsStack)

        searchGameButton.addTarget(controller, action: #selector(controller.onSearchGameTap), for: .touchUpInside)
        createGameButton.addTarget(controller, action: #selector(controller.onCreateGameTap), for: .touchUpInside)
    }
}


// MARK: - Constraints
private extension MainMenuView {
    func updateButtonsStackConstraints() {
        NSLayoutConstraint.activate([
            buttonsStack.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor, constant: Constants.buttonsStackCenterYOffset),
            buttonsStack.leftAnchor.constraint(equalTo: leftAnchor, constant: AutoLayout.Constants.baseHorizontalInset),
            buttonsStack.rightAnchor.constraint(equalTo: rightAnchor, constant: -AutoLayout.Constants.baseHorizontalInset)
        ])
    }
}
