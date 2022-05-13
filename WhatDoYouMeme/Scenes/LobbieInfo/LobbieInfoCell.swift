//
//  LobbieInfoCell.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 13.05.2022.
//

import UIKit

final class LobbieInfoCell: UITableViewCell {
    private enum Constants {
        static let mainCardVerticalInsets: CGFloat = .zero
        static let horizontalStackVerticalInsets: CGFloat = 16
        static let horizontalStackSpacing: CGFloat = 8
        static let cardCornerRadius: CGFloat = 24
    }

    enum State {
        case first
        case middle
        case last
        case only
    }


    static let identifier: String = "LobbieInfoCell"


    private let mainCardView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .mainCardViewInCellBackground
        $0.clipsToBounds = true
        $0.layer.cornerRadius = Constants.cardCornerRadius
        return $0
    }(UIView())
    private let horizontalStack: UIStackView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .horizontal
        $0.spacing = Constants.horizontalStackSpacing
        return $0
    }(UIStackView())
    private let nameLabel: UILabel = {
        $0.numberOfLines = .zero
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return $0
    }(UILabel())
    private let readyLabel: UILabel = {
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        $0.textAlignment = .right
        return $0
    }(UILabel())


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        super.updateConstraints()
        updateMainCardViewConstraints()
        updateHorizontalStackConstraints()
    }


    func updateData(_ player: Player, isReady: Bool, state: State = .middle) {
        nameLabel.text = player.name
        let textColor = isReady ? UIColor.lobbieInfoReadyCellTextColor : UIColor.lobbieInfoNotReadyCellTextColor
        nameLabel.textColor = textColor
        readyLabel.textColor = textColor
        mainCardView.backgroundColor = isReady ? UIColor.lobbieInfoReadyCellBackground : UIColor.mainCardViewInCellBackground
        readyLabel.text = isReady ? LocalizedString.LobbieInfo.ready : LocalizedString.LobbieInfo.notReady

        var cornersToMask: CACornerMask = []
        switch state {
        case .first:
            cornersToMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .middle:
            cornersToMask = []
        case .last:
            cornersToMask = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .only:
            cornersToMask = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner]
        }
        mainCardView.layer.maskedCorners = cornersToMask
    }
}


// MARK: - Private
private extension LobbieInfoCell {
    func setupCell() {
        setNeedsUpdateConstraints()
        contentView.backgroundColor = .background

        horizontalStack.addArrangedSubviews(nameLabel, readyLabel)
        mainCardView.addSubview(horizontalStack)
        contentView.addSubview(mainCardView)
    }
}


// MARK: - Constraints
private extension LobbieInfoCell {
    func updateHorizontalStackConstraints() {
        NSLayoutConstraint.activate([
            horizontalStack.topAnchor.constraint(equalTo: mainCardView.topAnchor, constant: Constants.horizontalStackVerticalInsets),
            horizontalStack.bottomAnchor.constraint(equalTo: mainCardView.bottomAnchor, constant: -Constants.horizontalStackVerticalInsets),
            horizontalStack.leftAnchor.constraint(equalTo: mainCardView.leftAnchor, constant: GlobalConstants.AutoLayout.baseHorizontalInset),
            horizontalStack.rightAnchor.constraint(equalTo: mainCardView.rightAnchor, constant: -GlobalConstants.AutoLayout.baseHorizontalInset)
        ])
    }

    func updateMainCardViewConstraints() {
        NSLayoutConstraint.activate([
            mainCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.mainCardVerticalInsets),
            mainCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.mainCardVerticalInsets),
            mainCardView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: GlobalConstants.AutoLayout.baseHorizontalInset),
            mainCardView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -GlobalConstants.AutoLayout.baseHorizontalInset)
        ])
    }
}
