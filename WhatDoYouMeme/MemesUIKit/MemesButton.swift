//
//  MemesButton.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 11.05.2022.
//

import UIKit

final class MemesButton: UIButton {

    enum Style {
        case primary
        case `default`
    }

    enum Constants {
        static let cornerRadius: CGFloat = 16
        static let buttonHeight: CGFloat = 50

        static let highlightedAlpha: CGFloat = 0.3
        static let defaultAlpha: CGFloat = 1
        static let highlightDuration: TimeInterval = 0.3
    }


    override var isHighlighted: Bool {
        willSet {
            onHighlightedChange(newValue)
        }
    }


    private let style: Style


    init(
        title: String,
        style: Style = .default
    ) {
        self.style = style
        super.init(frame: .zero)
        self.setTitle(title, for: .normal)
        setupButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        super.updateConstraints()
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }
}


private extension MemesButton {
    func setupButton() {
        setNeedsUpdateConstraints()
        layer.cornerRadius = Constants.cornerRadius
        setupStyle()
    }

    func setupStyle() {
        switch style {
        case .primary:
            setupPrimaryStyle()
        case .default:
            setupDefaultStyle()
        }
    }

    func setupPrimaryStyle() {
        backgroundColor = .primaryButton
    }

    func setupDefaultStyle() {
        backgroundColor = .defaultButton
        setTitleColor(.defaultButtonTitle, for: .normal)
    }


    func onHighlightedChange(_ isHighlighted: Bool) {
        if isHighlighted {
            alpha = Constants.highlightedAlpha
        } else {
            UIView.animate(
                withDuration: Constants.highlightDuration,
                delay: .zero,
                options: [.allowUserInteraction]) {
                    self.alpha = Constants.defaultAlpha
                }
        }
    }
}
