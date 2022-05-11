//
//  BigFactory.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 11.05.2022.
//

import UIKit

final class BigFactory {
    func makeMainMenuVC(withNavigator: Bool = false) -> UIViewController {
        let mainMenuVC = MainMenuController()
        return withNavigator ? mainMenuVC.navigated(by: makeNavigator()) : mainMenuVC
    }

    func makeSettingsVC(withNavigator: Bool = false) -> UIViewController {
        let settingsVC = SettingsController()
        return withNavigator ? settingsVC.navigated(by: makeNavigator()) : settingsVC
    }

    func makeLobbiesListVC(withNavigator: Bool = false) -> UIViewController {
        let lobbiesListVC = LobbiesListController()
        return withNavigator ? lobbiesListVC.navigated(by: makeNavigator()) : lobbiesListVC
    }

    func makeCreateGameVC(withNavigator: Bool = false) -> UIViewController {
        let createGameVC = CreateGameController()
        return withNavigator ? createGameVC.navigated(by: makeNavigator()) : createGameVC
    }
}


private extension BigFactory {
    func makeNavigator() -> UINavigationController {
        let navigator = UINavigationController()
        return navigator
    }
}
