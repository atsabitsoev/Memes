//
//  SceneDelegate.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 11.05.2022.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    private let factory = BigFactory()
    private let firestore = FirestoreService.shared


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        window?.rootViewController = factory.makeMainMenuVC(withNavigator: true)
        window?.makeKeyAndVisible()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        firestore.quitFromLobbie(saveLastLobbie: true)
        firestore.setOnlineInCurrentGame(false)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        firestore.enterLastLobbie()
        firestore.setOnlineInCurrentGame(true)
    }
}

