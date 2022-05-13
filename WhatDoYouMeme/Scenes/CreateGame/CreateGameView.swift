//
//  CreateGameView.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 11.05.2022.
//

import UIKit

final class CreateGameView: UIView {
    private enum Constants {
        static let stackViewSpacing: CGFloat = 8
    }


    private unowned let controller: CreateGameController
    private let keyboard = KeyboardNotificationsObserver()


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
        $0.spacing = Constants.stackViewSpacing
        return $0
    }(UIStackView())

    private let nameTextfield: UITextField = MemesTextfield(placeholder: LocalizedString.CreateGame.nameTextfieldPlaceholder)

    private let createButton: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isEnabled = false
        return $0
    }(MemesButton(title: LocalizedString.CreateGame.createButtonTitle, style: .primary))

    private let loader: UIActivityIndicatorView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isHidden = true
        return $0
    }(UIActivityIndicatorView())


    private lazy var createButtonBottomAnchor: NSLayoutConstraint = { [unowned self] in
        self.createButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -GlobalConstants.AutoLayout.baseBottomInset)
    }()


    private var shouldAnimateLayout: Bool!


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
        updateCreateButtonConstraints()
        updateLoaderConstraints()
    }


    func activateNameTextfield() {
        nameTextfield.becomeFirstResponder()
    }

    func hideKeyboard() {
        endEditing(true)
    }

    func enableLayoutAnimation(_ enable: Bool) {
        shouldAnimateLayout = enable
    }

    func setLoading(_ enable: Bool) {
        loader.isHidden = !enable
        enable ? loader.startAnimating() : loader.stopAnimating()
    }

    func enableCreateButton(_ enable: Bool) {
        createButton.isEnabled = enable
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
        addSubview(createButton)
        addSubview(loader)

        nameTextfield.addTarget(self, action: #selector(onNameTFChange), for: .editingChanged)
        createButton.addTarget(controller, action: #selector(controller.onCreateButtonTap), for: .touchUpInside)

        addTapGestureRec()
        setupKeyboard()
    }

    func addTapGestureRec() {
        let rec = UITapGestureRecognizer()
        addGestureRecognizer(rec)
        rec.addTarget(controller, action: #selector(controller.onViewTap))
    }

    func setupKeyboard() {
        keyboard.onWillShow = { [unowned self] info in
            let neededInset = info.endFrame.height
            self.createButtonBottomAnchor.constant = -neededInset
            self.updateLayoutWithAnimation()
        }
        keyboard.onWillHide = { [unowned self] info in
            self.createButtonBottomAnchor.constant = -GlobalConstants.AutoLayout.baseBottomInset
            self.updateLayoutWithAnimation()
        }
    }

    func updateLayoutWithAnimation() {
        guard shouldAnimateLayout else { return }
        UIView.animate(withDuration: GlobalConstants.Animation.baseAnimationDuration) {
            self.layoutIfNeeded()
        }
    }

    @objc
    func onNameTFChange() {
        guard let newValue = nameTextfield.text else { return }
        controller.updateLobbieName(newValue)
    }
}


// MARK: - Constraints
private extension CreateGameView {
    func updateScrollViewConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: createButton.topAnchor, constant: -GlobalConstants.AutoLayout.baseBottomInset),
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
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: GlobalConstants.AutoLayout.baseTopInset),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: GlobalConstants.AutoLayout.baseHorizontalInset),
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -GlobalConstants.AutoLayout.baseHorizontalInset)
        ])
    }

    func updateCreateButtonConstraints() {
        NSLayoutConstraint.activate([
            createButtonBottomAnchor,
            createButton.leftAnchor.constraint(equalTo: leftAnchor, constant: GlobalConstants.AutoLayout.baseHorizontalInset),
            createButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -GlobalConstants.AutoLayout.baseHorizontalInset)
        ])
    }

    func updateLoaderConstraints() {
        NSLayoutConstraint.activate([
            loader.topAnchor.constraint(equalTo: topAnchor),
            loader.bottomAnchor.constraint(equalTo: bottomAnchor),
            loader.leftAnchor.constraint(equalTo: leftAnchor),
            loader.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
}
