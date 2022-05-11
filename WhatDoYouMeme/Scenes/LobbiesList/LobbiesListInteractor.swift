//
//  LobbiesInteractor.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 11.05.2022.
//

import Foundation

final class LobbiesListInteractor {
    private let firestore = FirestoreService()


    func getLobbies(_ handler: @escaping (([Lobbie]) -> Void)) {
        firestore.getLobbiesList(handler)
    }
}
