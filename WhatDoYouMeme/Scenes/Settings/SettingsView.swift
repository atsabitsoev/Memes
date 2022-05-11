//
//  SettingsView.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 11.05.2022.
//

import UIKit

final class SettingsView: UIView {
    private unowned let controller: SettingsController


    init(controller: SettingsController) {
        self.controller = controller
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Private
private extension SettingsView {
    func setupView() {
        backgroundColor = UIColor.background
        setNeedsUpdateConstraints()
    }
}
