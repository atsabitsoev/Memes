//
//  Strings+Keys.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 11.05.2022.
//

import Foundation

enum LocalizedString {
    enum MainMenu {
        static var title: String { "mainMenu.title".localized() }
        static var searchGame: String { "mainMenu.searchGame".localized() }
        static var createGame: String { "mainMenu.createGame".localized() }
    }
    enum Settings {
        static var title: String { "settings.title".localized() }
    }
    enum LobbiesList {
        static var title: String { "lobbiesList.title".localized() }
    }
    enum LobbieInfo {
        static var closeAlertMessage: String { "lobbieInfo.closeAlertMessage".localized() }
        static var closeAlertOkAction: String { "lobbieInfo.closeAlertOkAction".localized() }
        static var closeAlertCancelAction: String { "lobbieInfo.closeAlertCancelAction".localized() }
        static var ready: String { "lobbieInfo.ready".localized() }
        static var notReady: String { "lobbieInfo.notReady".localized() }
    }
    enum CreateGame {
        static var title: String { "createGame.title".localized() }

        static var closeAlertTitle: String { "createGame.closeAlertTitle".localized() }
        static var closeAlertMessage: String { "createGame.closeAlertMessage".localized() }
        static var closeAlertOkAction: String { "createGame.closeAlertOkAction".localized() }
        static var closeAlertCancelAction: String { "createGame.closeAlertCancelAction".localized() }

        static var nameTextfieldPlaceholder: String { "createGame.nameTextfieldPlaceholder".localized() }
        static var createButtonTitle: String { "createGame.createButtonTitle".localized() }
    }
    enum Game {
        static var closeAlertMessage: String { "game.closeAlertMessage".localized() }
        static var closeAlertOkAction: String { "game.closeAlertOkAction".localized() }
        static var closeAlertCancelAction: String { "game.closeAlertCancelAction".localized() }

        static var sendCard: String { "game.sendCard".localized() }
    }
    enum StepResults {
        static var title: String { "stepResults.title".localized() }
        static var nextButtonTitle: String { "stepResults.nextButtonTitle".localized() }
    }
    enum ErrorAlertDefault {
        static var title: String { "errorAlertDefault.title".localized() }
        static var message: String { "errorAlertDefault.message".localized() }
        static var okAction: String { "errorAlertDefault.okAction".localized() }
    }
}


private extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: .empty)
    }
}
