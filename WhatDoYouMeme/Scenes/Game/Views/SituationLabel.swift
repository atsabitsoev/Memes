//
//  SituationLabel.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 21.05.2022.
//

import UIKit

final class SituationLabel: UILabel {


    init() {
        super.init(frame: .zero)
        numberOfLines = .zero
        textAlignment = .center
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
