//
//  GameView.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 13.05.2022.
//

import UIKit

final class GameView: UIView {
    private unowned let controller: GameController


    private let situationLabel: SituationLabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(SituationLabel())
    private let handView: HandView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(HandView())


    init(controller: GameController) {
        self.controller = controller
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        super.updateConstraints()
        setSituationLabelConstraints()
        setHandViewConstraints()
    }


    func setGame(_ game: Game) {
        let currentStepIndex = game.currentStep.index
        situationLabel.text = game.situations[currentStepIndex]
        handView.update(cardsLinks: game.getMyHand(), sentCard: game.getMySentCard())
    }

    func setOnCardConfigmedHandler(_ handler: @escaping (String) -> Void) {
        handView.setOnCardConfirmedHandler(handler)
    }
}


// MARK: - Private
private extension GameView {
    func setupView() {
        backgroundColor = .background
        setNeedsUpdateConstraints()

        addSubview(situationLabel)
        addSubview(handView)
    }
}


// MARK: - Constraints
private extension GameView {
    func setSituationLabelConstraints() {
        NSLayoutConstraint.activate([
            situationLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: GlobalConstants.AutoLayout.baseHorizontalInset),
            situationLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -GlobalConstants.AutoLayout.baseHorizontalInset),
            situationLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: GlobalConstants.AutoLayout.baseTopInset)
        ])
    }

    func setHandViewConstraints() {
        NSLayoutConstraint.activate([
            handView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            handView.leftAnchor.constraint(equalTo: leftAnchor),
            handView.rightAnchor.constraint(equalTo: rightAnchor),
            handView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3)
        ])
    }
}
