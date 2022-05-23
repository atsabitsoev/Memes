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
        static let disabledAlpha: CGFloat = 0.3
        static let defaultAlpha: CGFloat = 1
        static let highlightDuration: TimeInterval = 0.3
    }


    override var isHighlighted: Bool {
        willSet {
            onHighlightedChange(newValue)
        }
    }

    override var isEnabled: Bool {
        willSet {
            onEnabledChange(newValue)
        }
    }


    private var style: Style


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
        updateButtonConstraints()
    }

    func updateStyle(_ style: Style) {
        self.style = style
        setupStyle()
    }
}


// MARK: - Private
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
        backgroundColor = .primary
        setTitleColor(.primaryButtonTitle, for: .normal)
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

    func onEnabledChange(_ isEnabled: Bool) {
        isUserInteractionEnabled = isEnabled
        alpha = isEnabled ? Constants.defaultAlpha : Constants.disabledAlpha
    }
}


// MARK: - Constraints
private extension MemesButton {
    func updateButtonConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }
}
