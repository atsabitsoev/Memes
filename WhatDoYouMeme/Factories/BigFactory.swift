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
        let interactor = MainMenuInteractor()
        let mainMenuVC = MainMenuController(interactor: interactor, coordinator: coordinator)
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

    func makeLobbieInfoVC(lobbieId: String, withNavigator: Bool = false) -> UIViewController {
        let interactor = LobbieInfoInteractor()
        let coordinator = LobbieInfoCoordinator()
        let lobbieInfoVC = LobbieInfoController(interactor: interactor, coordinator: coordinator, lobbieId: lobbieId)
        return withNavigator ? lobbieInfoVC.navigated(by: makeNavigator()) : lobbieInfoVC
    }

    func makeCreateGameVC(withNavigator: Bool = false) -> UIViewController {
        let interactor = CreateGameInteractor()
        let coordinator = CreateGameCoordinator()
        let createGameVC = CreateGameController(interactor: interactor, coordinator: coordinator)
        return withNavigator ? createGameVC.navigated(by: makeNavigator()) : createGameVC
    }

    func makeGameVC(gameId: String, withNavigator: Bool = false) -> UIViewController {
        let interactor = GameInteractor()
        let coordinator = GameCoordinator()
        let gameVC = GameController(interactor: interactor, coordinator: coordinator, gameId: gameId)
        return withNavigator ? gameVC.navigated(by: makeNavigator()) : gameVC
    }

    func makeStepResultsVC(
        situation: String,
        steppedPlayers: [Game.Step.SteppedPlayer],
        withNavigator: Bool = false
    ) -> UIViewController {
        let interactor = StepResutlsInteractor()
        let stepResultsVC = StepResultsController(
            interactor: interactor,
            situation: situation,
            steppedPlayers: steppedPlayers
        )
        return withNavigator ? stepResultsVC.navigated(by: makeNavigator()) : stepResultsVC
    }
}


private extension BigFactory {
    func makeNavigator() -> UINavigationController {
        let navigator = UINavigationController()
        navigator.navigationBar.isTranslucent = false

        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor.background
        appearance.shadowColor = nil

        navigator.navigationBar.standardAppearance = appearance
        navigator.navigationBar.scrollEdgeAppearance = navigator.navigationBar.standardAppearance

        return navigator
    }
}
