//
//  BigFactory.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 11.05.2022.
//

import UIKit

final class BigFactory {
    func makeMainMenuVC(withNavigator: Bool = false) -> UIViewController {
        let coordinator = MainMenuCoordinator()
        let mainMenuVC = MainMenuController(coordinator: coordinator)
        return withNavigator ? mainMenuVC.navigated(by: makeNavigator()) : mainMenuVC
    }

    func makeSettingsVC(withNavigator: Bool = false) -> UIViewController {
        let settingsVC = SettingsController()
        return withNavigator ? settingsVC.navigated(by: makeNavigator()) : settingsVC
    }

    func makeLobbiesListVC(withNavigator: Bool = false) -> UIViewController {
        let interactor = LobbiesListInteractor()
        let coordinator = LobbiesListCoordinator()
        let lobbiesListVC = LobbiesListController(interactor: interactor, coordinator: coordinator)
        return withNavigator ? lobbiesListVC.navigated(by: makeNavigator()) : lobbiesListVC
    }

    func makeLobbieInfoVC(lobbie: Lobbie, withNavigator: Bool = false) -> UIViewController {
        let interactor = LobbieInfoInteractor()
        let lobbieInfoVC = LobbieInfoController(interactor: interactor, lobbie: lobbie)
        return withNavigator ? lobbieInfoVC.navigated(by: makeNavigator()) : lobbieInfoVC
    }

    func makeCreateGameVC(withNavigator: Bool = false) -> UIViewController {
        let interactor = CreateGameInteractor()
        let coordinator = CreateGameCoordinator()
        let createGameVC = CreateGameController(interactor: interactor, coordinator: coordinator)
        return withNavigator ? createGameVC.navigated(by: makeNavigator()) : createGameVC
    }
}


private extension BigFactory {
    func makeNavigator() -> UINavigationController {
        let navigator = UINavigationController()
        return navigator
    }
}
