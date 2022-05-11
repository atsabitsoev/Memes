//
//  MainMenuCoordinator.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 11.05.2022.
//

import UIKit

final class MainMenuCoordinator {
    private let factory = BigFactory()


    func showSettings(fromVC vc: UIViewController) {
        let settingsVC = factory.makeSettingsVC()
        vc.open(vc: settingsVC)
    }

    func showLobbiesList(fromVC vc: UIViewController) {
        let lobbiesListVC = factory.makeLobbiesListVC(withNavigator: true)
        vc.open(vc: lobbiesListVC, inStack: false)
    }

    func showCreateGame(fromVC vc: UIViewController) {
        let createGameVC = factory.makeCreateGameVC(withNavigator: true)
        vc.open(vc: createGameVC, inStack: false)
    }
}
