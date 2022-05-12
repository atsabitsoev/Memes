//
//  CreateGameInteractor.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 12.05.2022.
//

import Foundation

final class CreateGameInteractor {
    private let firestore: FirestoreService = FirestoreService()


    func createLobbie(withName name: String, _ handler: @escaping (Lobbie?) -> Void) {
        firestore.createLobbie(withName: name, handler)
    }
}
