//
//  LobbiesListController.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 11.05.2022.
//

import UIKit

final class LobbiesListController: UIViewController {
    private var lobbiesListView: LobbiesListView!


    override func loadView() {
        super.loadView()
        lobbiesListView = LobbiesListView(controller: self)
        view = lobbiesListView
        title = LocalizedString.LobbiesList.title
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addCloseButton()
    }
}
