//
//  StepResultsController.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 26.05.2022.
//

import UIKit

final class StepResultsController: UIViewController {
    private var stepResultsView: StepResultsView!
    private let interactor: StepResutlsInteractor


    private let situation: String
    private let steppedPlayers: [Game.Step.SteppedPlayer]


    init(
        interactor: StepResutlsInteractor,
        situation: String,
        steppedPlayers: [Game.Step.SteppedPlayer]
    ) {
        self.interactor = interactor
        self.situation = situation
        self.steppedPlayers = steppedPlayers
        print(situation)
        print("cards:\n\(steppedPlayers.map({ $0.card + "\n" }))")
        print("refs:\n\(steppedPlayers.map({ $0.ref + "\n" }))")
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        stepResultsView = StepResultsView(controller: self)
        view = stepResultsView
        title = LocalizedString.StepResults.title
    }
}
