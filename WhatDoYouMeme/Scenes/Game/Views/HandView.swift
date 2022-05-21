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
        static let stackHeightInset: CGFloat = 1
    }


    private let stackView: UIStackView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .horizontal
        $0.spacing = Constants.stackSpacing
        return $0
    }(UIStackView())


    private var cardsLinks: [String] {
        didSet {
            updateCards()
        }
    }


    init(cardsLinks: [String] = []) {
        self.cardsLinks = cardsLinks
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


    func update(cardsLinks: [String]) {
        self.cardsLinks = cardsLinks
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
        let cardViews: [UIView] = cardsLinks.map(CardView.init)
        stackView.addArrangedSubviews(cardViews)
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
