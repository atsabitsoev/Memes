//
//  CreateGameView.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 11.05.2022.
//

import UIKit

final class CreateGameView: UIView {
    private unowned let controller: CreateGameController


    private let scrollView: UIScrollView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIScrollView())

    private let contentView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())

    private let stackView: UIStackView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.spacing = 8
        return $0
    }(UIStackView())

    private let nameTextfield: UITextField = MemesTextfield(placeholder: LocalizedString.CreateGame.nameTextfieldPlaceholder)
    private let createButton: UIButton = MemesButton(title: LocalizedString.CreateGame.createButtonTitle, style: .primary)


    init(controller: CreateGameController) {
        self.controller = controller
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        super.updateConstraints()
        updateScrollViewConstraints()
        updateContentViewConstraints()
        updateStackViewConstraints()
    }


    func activateNameTextfield() {
        nameTextfield.becomeFirstResponder()
    }

    func hideKeyboard() {
        endEditing(true)
    }
}


// MARK: - Private
private extension CreateGameView {
    func setupView() {
        backgroundColor = .background
        setNeedsUpdateConstraints()

        stackView.addArrangedSubviews(nameTextfield)
        contentView.addSubview(stackView)
        scrollView.addSubview(contentView)
        addSubview(scrollView)

        addTapGestureRec()
    }

    func addTapGestureRec() {
        let rec = UITapGestureRecognizer()
        addGestureRecognizer(rec)
        rec.addTarget(controller, action: #selector(controller.onViewTap))
    }
}


// MARK: - Constraints
private extension CreateGameView {
    func updateScrollViewConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }

    func updateContentViewConstraints() {
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    func updateStackViewConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: AutoLayout.Constants.baseTopInset),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: AutoLayout.Constants.baseHorizontalInset),
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -AutoLayout.Constants.baseHorizontalInset)
        ])
    }
}
