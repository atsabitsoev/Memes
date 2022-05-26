//
//  GameCoordinator.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 26.05.2022.
//

import UIKit

final class GameCoordinator {
    private let factory = BigFactory()


    func showStepResultsVC(
        situation: String,
        steppedPlayers: [Game.Step.SteppedPlayer],
        fromVC: UIViewController
    ) {
        let stepResultsVC = factory.makeStepResultsVC(
            situation: situation,
            steppedPlayers: steppedPlayers,
            withNavigator: true
        )
        fromVC.open(vc: stepResultsVC, inStack: false)
    }
}
