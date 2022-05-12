//
//  LobbiesListCell.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 11.05.2022.
//

import UIKit

final class LobbiesListCell: UITableViewCell {
    private enum Constants {
        static let mainCardVerticalInsets: CGFloat = 6
        static let horizontalStackVerticalInsets: CGFloat = 16
        static let horizontalStackSpacing: CGFloat = 8
        static let cardCornerRadius: CGFloat = 16
        static let highlightDuration: CGFloat = 0.3
    }


    static let identifier: String = "LobbiesListCell"


    private let mainCardView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .lobbieListCardBackground
        $0.layer.cornerRadius = Constants.cardCornerRadius
        $0.clipsToBounds = true
        return $0
    }(UIView())
    private let horizontalStack: UIStackView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = Constants.horizontalStackSpacing
        return $0
    }(UIStackView())
    private let titleLabel: UILabel = {
        $0.numberOfLines = .zero
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return $0
    }(UILabel())
    private let countLabel: UILabel = {
        $0.textAlignment = .right
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        return $0
    }(UILabel())
    private let disclosureImageView: UIImageView = {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = UIColor.disclosureIndicator
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        return $0
    }(UIImageView())


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

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        mainCardView.backgroundColor = highlighted || isSelected ? UIColor.lobbieListCardHighlighted : UIColor.lobbieListCardBackground
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        mainCardView.backgroundColor = selected || isHighlighted ? UIColor.lobbieListCardHighlighted : UIColor.lobbieListCardBackground
    }


    func updateData(_ lobbie: Lobbie) {
        titleLabel.text = lobbie.name
        countLabel.text = "\(lobbie.membersPaths.count)" + " участн."
    }
}


// MARK: - Private
private extension LobbiesListCell {
    func setupCell() {
        setNeedsUpdateConstraints()
        contentView.backgroundColor = .background

        horizontalStack.addArrangedSubviews(titleLabel, countLabel, disclosureImageView)
        mainCardView.addSubview(horizontalStack)
        contentView.addSubview(mainCardView)
    }
}


// MARK: - Constraints
private extension LobbiesListCell {
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
