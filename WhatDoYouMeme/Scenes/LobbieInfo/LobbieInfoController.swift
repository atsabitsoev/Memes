//
//  LobbieInfoController.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 12.05.2022.
//

import UIKit

final class LobbieInfoController: UIViewController {
    private var lobbieInfoView: LobbieInfoView!
    private let interactor: LobbieInfoInteractor


    private let lobbie: Lobbie


    init(interactor: LobbieInfoInteractor, lobbie: Lobbie) {
        self.interactor = interactor
        self.lobbie = lobbie
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        lobbieInfoView = LobbieInfoView(controller: self)
        view = lobbieInfoView
        title = lobbie.name
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addCloseButton()
    }

    override func onCloseTap() {
        closeAlert()
    }
}


// MARK: - Private
private extension LobbieInfoController {
    func closeAlert() {
        let alert = UIAlertController(
            title: nil,
            message: LocalizedString.LobbieInfo.closeAlertMessage,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(
            title: LocalizedString.LobbieInfo.closeAlertOkAction,
            style: .default) { _ in super.onCloseTap() }
        let cancelAction = UIAlertAction(
            title: LocalizedString.LobbieInfo.closeAlertCancelAction,
            style: .cancel
        )
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
}
