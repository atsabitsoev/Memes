//
//  LobbiesListView.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 11.05.2022.
//

import UIKit

final class LobbiesListView: UIView {
    private unowned let controller: LobbiesListController


    init(controller: LobbiesListController) {
        self.controller = controller
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Private
private extension LobbiesListView {
    func setupView() {
        backgroundColor = .background
        setNeedsUpdateConstraints()
    }
}
