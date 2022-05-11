//
//  LobbiesListController.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 11.05.2022.
//

import UIKit

final class LobbiesListController: UIViewController {
    private var lobbiesListView: LobbiesListView!
    private let interactor: LobbiesListInteractor


    private(set) var lobbies: [Lobbie] = []


    init(interactor: LobbiesListInteractor) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        lobbiesListView = LobbiesListView(controller: self)
        view = lobbiesListView
        title = LocalizedString.LobbiesList.title
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addCloseButton()
        loadLobbies()
    }
}


// MARK: - Private
private extension LobbiesListController {
    func loadLobbies() {
        interactor.getLobbies { [weak self] lobbies in
            guard let strongSelf = self else { return }
            strongSelf.lobbies = lobbies
            strongSelf.lobbiesListView.reloadData()
        }
    }
}
