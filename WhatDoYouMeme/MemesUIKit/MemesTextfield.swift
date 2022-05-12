//
//  MemesTextField.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 12.05.2022.
//

import UIKit

final class MemesTextfield: UITextField {
    private enum Constants {
        static let cornerRadius: CGFloat = 8
        static let textFieldHeight: CGFloat = 50
        static let textRectInsets: UIEdgeInsets = .init(
            top: .zero,
            left: AutoLayout.Constants.baseHorizontalInset,
            bottom: .zero,
            right: AutoLayout.Constants.baseHorizontalInset
        )
    }


    init(placeholder: String? = nil) {
        super.init(frame: .zero)
        self.placeholder = placeholder
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        super.updateConstraints()
        updateTextFieldConstraints()
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: Constants.textRectInsets)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: Constants.textRectInsets)
    }
}


// MARK: - Private
private extension MemesTextfield {
    func setupView() {
        backgroundColor = .textfieldBackground
        setNeedsUpdateConstraints()
        layer.cornerRadius = Constants.cornerRadius
    }
}


// MARK: - Constraints
private extension MemesTextfield {
    func updateTextFieldConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Constants.textFieldHeight)
        ])
    }
}
