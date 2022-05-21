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


    private let imageView: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .cardPlaceholder
        $0.clipsToBounds = true
        return $0
    }(UIImageView())


    init(imageLink: String) {
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
    }
}


// MARK: - Private
private extension CardView {
    func setupView() {
        backgroundColor = .cardBackground
        setNeedsUpdateConstraints()
        layer.cornerRadius = 8

        addSubview(imageView)
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
}
