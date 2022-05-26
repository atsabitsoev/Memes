//
//  StepResultsView.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 26.05.2022.
//

import UIKit

final class StepResultsView: UIView {
    private let controller: StepResultsController


    private let nextButton: MemesButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(MemesButton(title: LocalizedString.StepResults.nextButtonTitle, style: .primary))


    init(controller: StepResultsController) {
        self.controller = controller
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        super.updateConstraints()
        updateNextButtonConstraints()
    }
}


// MARK: - Private
private extension StepResultsView {
    func setupView() {
        backgroundColor = .background
        setNeedsUpdateConstraints()

        addSubview(nextButton)
    }
}


// MARK: - Constraints
private extension StepResultsView {
    func updateNextButtonConstraints() {
        NSLayoutConstraint.activate([
            nextButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -GlobalConstants.AutoLayout.baseBottomInset),
            nextButton.leftAnchor.constraint(equalTo: leftAnchor, constant: GlobalConstants.AutoLayout.baseHorizontalInset),
            nextButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -GlobalConstants.AutoLayout.baseHorizontalInset)
        ])
    }
}
