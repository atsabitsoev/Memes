//
//  UIStackView+Extension.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 11.05.2022.
//

import UIKit

extension UIStackView {
    func addArrangedSubviews(_ subviews: UIView...) {
        addArrangedSubviews(subviews)
    }

    func addArrangedSubviews(_ subviews: [UIView]) {
        subviews.forEach({ addArrangedSubview($0) })
    }

    func removeAllArrangedSubviews() {
        arrangedSubviews.forEach { view in
            removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
}
