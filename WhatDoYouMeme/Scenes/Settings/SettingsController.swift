//
//  SettingsController.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 11.05.2022.
//

import UIKit

final class SettingsController: UIViewController {
    private var settingsView: SettingsView!


    override func loadView() {
        super.loadView()
        settingsView = SettingsView(controller: self)
        view = settingsView
        title = LocalizedString.Settings.title
    }
}
