//
//  LobbieInfoView.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 12.05.2022.
//

import UIKit

final class LobbieInfoView: UIView {
    private unowned let controller: LobbieInfoController


    init(controller: LobbieInfoController) {
        self.controller = controller
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        super.updateConstraints()
    }
}


// MARK: - Private
private extension LobbieInfoView {
    func setupView() {
        backgroundColor = .background
        setNeedsUpdateConstraints()
    }
}
