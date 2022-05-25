//
//  CardView.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 21.05.2022.
//

import UIKit
import SDWebImage

final class CardView: UIView {
    private enum Constants {
        static let imageViewInsets: CGFloat = 16
        static let aspectRatio: CGFloat = 3/2
    }

    enum State {
        struct Configuration {
            static var normalConfiguration: Configuration { Configuration(backgroundColor: .cardNormalBackground) }
            static var selectedConfiguration: Configuration { Configuration(backgroundColor: .cardSelectedBackground, imageViewAlpha: 0.5, mainButtonTitle: LocalizedString.Game.sendCard) }
            static var loadingConfiguration: Configuration { Configuration(backgroundColor: .cardSelectedBackground, imageViewAlpha: 0.5, activityIsHidden: false) }
            static var sentConfiguration: Configuration { Configuration(backgroundColor: .cardSentBackground, imageViewAlpha: 0.5) }

            let backgroundColor: UIColor
            let imageViewAlpha: CGFloat
            let mainButtonTitle: String
            let activityIsHidden: Bool

            private init(
                backgroundColor: UIColor,
                imageViewAlpha: CGFloat = 1,
                mainButtonTitle: String = .empty,
                activityIsHidden: Bool = true
            ) {
                self.backgroundColor = backgroundColor
                self.imageViewAlpha = imageViewAlpha
                self.mainButtonTitle = mainButtonTitle
                self.activityIsHidden = activityIsHidden
            }
        }

        case normal
        case selected
        case loading
        case sent

        func getConfiguration() -> Configuration {
            switch self {
            case .normal: return .normalConfiguration
            case .selected: return .selectedConfiguration
            case .loading: return .loadingConfiguration
            case .sent: return .sentConfiguration
            }
        }

        func getNextStateOntap() -> State? {
            switch self {
            case .normal: return .selected
            case .selected: return .loading
            case .loading, .sent: return nil
            }
        }
    }


    private let imageView: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .cardPlaceholder
        $0.clipsToBounds = true
        return $0
    }(UIImageView())
    private let mainButton: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitleColor(UIColor.primary, for: .normal)
        return $0
    }(UIButton())
    private let activityIndicator: UIActivityIndicatorView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.style = .large
        $0.hidesWhenStopped = true
        return $0
    }(UIActivityIndicatorView())


    private(set) var state: State {
        didSet {
            updateState()
        }
    }

    private var onSelectHandler: (() -> Void)?
    private var onLoadingHandler: (() -> Void)?


    init(imageLink: String, state: State = .normal) {
        self.state = state
        super.init(frame: .zero)
        imageView.sd_setImage(with: URL(string: imageLink))
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        super.updateConstraints()
        setViewConstraints()
        setImageViewConstraints()
        setActivityConstraints()
        setMainButtonConstraints()
    }


    func resetState() {
        state = .normal
    }

    func blockCard() {
        if mainButton.isEnabled {
            mainButton.isEnabled = false
            mainButton.isUserInteractionEnabled = false
        }
    }

    func setOnSelectHandler(_ handler: @escaping () -> Void) {
        onSelectHandler = handler
    }

    func setOnLoadingHandler(_ handler: @escaping () -> Void) {
        onLoadingHandler = handler
    }
}


// MARK: - Private
private extension CardView {
    func setupView() {
        setNeedsUpdateConstraints()
        layer.cornerRadius = 8

        addSubview(imageView)
        addSubview(activityIndicator)
        addSubview(mainButton)

        updateState()

        mainButton.addTarget(self, action: #selector(onMainButtonTap), for: .touchUpInside)
    }

    func updateState() {
        if state == .selected {
            onSelectHandler?()
        } else if state == .loading {
            onLoadingHandler?()
        }

        let configuration = state.getConfiguration()
        backgroundColor = configuration.backgroundColor
        mainButton.setTitle(configuration.mainButtonTitle, for: .normal)
        configuration.activityIsHidden ? activityIndicator.stopAnimating() : activityIndicator.startAnimating()
        imageView.alpha = configuration.imageViewAlpha
    }
}


// MARK: - Actions
private extension CardView {
    @objc
    private func onMainButtonTap() {
        if let newState = state.getNextStateOntap() {
            state = newState
        }
    }
}


// MARK: - Constraints
private extension CardView {
    func setViewConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalTo: widthAnchor, multiplier: Constants.aspectRatio)
        ])
    }

    func setImageViewConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.imageViewInsets),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.imageViewInsets),
            imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: Constants.imageViewInsets),
            imageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -Constants.imageViewInsets)
        ])
    }

    func setActivityConstraints() {
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func setMainButtonConstraints() {
        NSLayoutConstraint.activate([
            mainButton.topAnchor.constraint(equalTo: topAnchor),
            mainButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainButton.leftAnchor.constraint(equalTo: leftAnchor),
            mainButton.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
}
