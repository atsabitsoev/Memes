//
//  FirestoreService.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 11.05.2022.
//

import FirebaseFirestore

final class FirestoreService {
    private let db = Firestore.firestore()

    private var temporaryPlayersArray: [Player] = []


    func getLobbiesList(_ handler: @escaping ([Lobbie]) -> Void) {
        db.collection(CollectionsKeys.lobbies.rawValue)
            .limit(to: 30)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {
                    print(error?.localizedDescription ?? "Неизвестная ошибка")
                    handler([])
                    return
                }
                let lobbies = snapshot.documents.map { document -> Lobbie in
                    let data = document.data()
                    let id = document.documentID
                    let name = data["name"] as? String ?? "Name"
                    let membersRefs = data["members"] as? [DocumentReference] ?? []
                    let membersPaths = membersRefs.map(\.path)
                    return Lobbie(id: id, name: name, membersPaths: membersPaths)
                }
                handler(lobbies)
            }
    }

    func getPlayers(byPaths paths: [String], _ handler: @escaping ([Player]) -> Void) {
        temporaryPlayersArray = []
        let playersRefs = paths.map({ db.document($0) })
        playersRefs.enumerated().forEach { (index, playerRef) in
            playerRef.addSnapshotListener { [weak self] snapshot, error in
                guard let snapshot = snapshot else {
                    print(error?.localizedDescription ?? "Неизвестная ошибка")
                    handler([])
                    return
                }
                let id = snapshot.documentID
                let data = snapshot.data() ?? [:]
                let name = data["name"] as? String ?? "Name"
                let player = Player(id: id, name: name)
                self?.temporaryPlayersArray.append(player)
                if paths.count == self?.temporaryPlayersArray.count {
                    handler(self?.temporaryPlayersArray ?? [])
                }
            }
        }
    }

    func createLobbie(withName name: String, _ handler: @escaping (Lobbie?) -> Void) {
        guard let userId = UserService.shared.getUserId() else { return }
        let currentPlayerRef = db.collection(CollectionsKeys.players.rawValue).document(userId)
        let members = [currentPlayerRef]
        let data: [String: Any] = [
            "name": name,
            "members": members
        ]
        let newDocumentRef = db.collection(CollectionsKeys.lobbies.rawValue).document()
        newDocumentRef.setData(data) { error in
            guard error == nil else {
                handler(nil)
                return
            }
            let membersPaths = members.map(\.path)
            let createdLobbie = Lobbie(id: newDocumentRef.documentID, name: name, membersPaths: membersPaths)
            handler(createdLobbie)
        }
    }
}


fileprivate enum CollectionsKeys: String {
    case lobbies
    case players
}
