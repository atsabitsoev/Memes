//
//  HandView.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 21.05.2022.
//

import UIKit

final class HandView: UIScrollView {
    private enum Constants {
        static let stackSpacing: CGFloat = 4
        static let stackSpacingAfterSentCardView: CGFloat = 8
        static let stackHeightInset: CGFloat = 1
    }


    private let stackView: UIStackView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .horizontal
        $0.spacing = Constants.stackSpacing
        return $0
    }(UIStackView())


    private var cardsLinks: [String]
    private var sentCard: String?

    private var onCardConfirmedHandler: ((String) -> Void)?


    init(cardsLinks: [String] = [], sentCard: String? = nil) {
        self.cardsLinks = cardsLinks
        self.sentCard = sentCard
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        super.updateConstraints()
        setStackViewConstraints()
    }


    func update(cardsLinks: [String], sentCard: String? = nil) {
        self.cardsLinks = cardsLinks
        self.sentCard = sentCard
        updateCards()
    }

    func setOnCardConfirmedHandler(_ handler: @escaping (String) -> Void) {
        onCardConfirmedHandler = handler
    }
}


// MARK: - Private
private extension HandView {
    func setupView() {
        setNeedsUpdateConstraints()
        contentInset = UIEdgeInsets(
            top: .zero,
            left: GlobalConstants.AutoLayout.baseHorizontalInset,
            bottom: .zero,
            right: GlobalConstants.AutoLayout.baseHorizontalInset
        )
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false

        addSubview(stackView)
        updateCards()
    }

    func updateCards() {
        stackView.removeAllArrangedSubviews()

        let cardViews: [UIView] = cardsLinks.map({
            let currentLink = $0
            let cardView = CardView(imageLink: currentLink)
            cardView.setOnSelectHandler { [weak self] in
                self?.resetAllCards(besides: cardView)
            }
            cardView.setOnLoadingHandler { [weak self] in
                self?.onCardConfirmedHandler?(currentLink)
                self?.blockAllCards()
            }
            return cardView
        })
        stackView.addArrangedSubviews(cardViews)

        if let sentCard = sentCard {
            let sentCardView = CardView(imageLink: sentCard, state: .sent)
            stackView.insertArrangedSubview(sentCardView, at: .zero)
            stackView.setCustomSpacing(Constants.stackSpacingAfterSentCardView, after: sentCardView)
            blockAllCards()
        }
    }

    func resetAllCards(besides selectedCard: CardView) {
        stackView.arrangedSubviews
            .compactMap({ $0 as? CardView })
            .filter({ $0 != selectedCard })
            .forEach { card in
                card.resetState()
            }
    }

    func blockAllCards() {
        stackView.arrangedSubviews
            .compactMap({ $0 as? CardView })
            .forEach { card in
                card.blockCard()
            }
    }
}


// MARK: - Constraints
private extension HandView {
    func setStackViewConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor),
            stackView.heightAnchor.constraint(equalTo: heightAnchor, constant: -Constants.stackHeightInset)
        ])
    }
}
