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
    enum CreateGame {
        static var title: String { "createGame.title".localized() }

        static var closeAlertTitle: String { "createGame.closeAlertTitle".localized() }
        static var closeAlertMessage: String { "createGame.closeAlertMessage".localized() }
        static var closeAlertOkAction: String { "createGame.closeAlertOkAction".localized() }
        static var closeAlertCancelAction: String { "createGame.closeAlertCancelAction".localized() }

        static var nameTextfieldPlaceholder: String { "createGame.nameTextfieldPlaceholder".localized() }
        static var createButtonTitle: String { "createGame.createButtonTitle".localized() }
    }
}


private extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: .empty)
    }
}
