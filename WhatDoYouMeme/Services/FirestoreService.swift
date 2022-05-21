//
//  FirestoreService.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 11.05.2022.
//

import FirebaseFirestore

final class FirestoreService {
    private init() {}
    static let shared = FirestoreService()
    private let db = Firestore.firestore()


    private var currentLobbieId: String?

    /// Сохраняется при сворачивании приложения
    private var lastLobbieId: String?


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
                let lobbies = snapshot.documents.compactMap(FirestoreService.documentToLobbie)
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
                let name = data[FieldsKeys.name.rawValue] as? String ?? "Name"
                let player = Player(id: id, name: name)
                self?.temporaryPlayersArray.append(player)
                if paths.count == self?.temporaryPlayersArray.count {
                    handler(self?.temporaryPlayersArray ?? [])
                }
            }
        }
    }

    func createLobbie(withName name: String, _ handler: @escaping (Lobbie?) -> Void) {
        let data: [String: Any] = [
            FieldsKeys.name.rawValue: name,
            FieldsKeys.members.rawValue: [],
            FieldsKeys.readyMembers.rawValue: [DocumentReference]()
        ]
        let newDocumentRef = db.collection(CollectionsKeys.lobbies.rawValue).document()
        newDocumentRef.setData(data) { error in
            guard error == nil else {
                handler(nil)
                return
            }
            let createdLobbie = Lobbie(
                id: newDocumentRef.documentID,
                name: name,
                membersPaths: [],
                readyMembersPaths: [],
                gameId: nil
            )
            handler(createdLobbie)
        }
    }

    func getLobbie(byId id: String, _ handler: @escaping (Lobbie?) -> Void) {
        db.collection(CollectionsKeys.lobbies.rawValue).document(id).addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                handler(nil)
                return
            }
            let lobbie = FirestoreService.documentToLobbie(snapshot)
            handler(lobbie)
        }
    }

    func toggleReady(inLobbie lobbieId: String, _ handler: @escaping () -> Void) {
        db.collection(CollectionsKeys.lobbies.rawValue).document(lobbieId).getDocument { [weak self] snapshot, error in
            guard let strongSelf = self, let snapshot = snapshot, let data = snapshot.data() else {
                handler()
                return
            }
            var readyMembers = data[FieldsKeys.readyMembers.rawValue] as? [DocumentReference] ?? []
            let readyMembersIds = readyMembers.map(\.documentID)
            guard let userId = UserService.shared.getUserId() else {
                handler()
                return
            }
            if let index = readyMembersIds.firstIndex(of: userId) {
                readyMembers.remove(at: index)
                snapshot.reference.setData([FieldsKeys.readyMembers.rawValue: readyMembers], mergeFields: [FieldsKeys.readyMembers.rawValue])
            } else {
                let currentPlayerRef = strongSelf.db.collection(CollectionsKeys.players.rawValue).document(userId)
                readyMembers.append(currentPlayerRef)
                snapshot.reference.setData([FieldsKeys.readyMembers.rawValue: readyMembers], mergeFields: [FieldsKeys.readyMembers.rawValue])
            }
            handler()
        }
    }

    func quitFromLobbie(saveLastLobbie: Bool = false, _ handler: (() -> Void)? = nil) {
        guard let lobbieId = currentLobbieId else { return }
        db.collection(CollectionsKeys.lobbies.rawValue).document(lobbieId).getDocument { [weak self] snapshot, error in
            guard let strongSelf = self, let snapshot = snapshot, let userId = UserService.shared.getUserId() else {
                handler?()
                return
            }
            var members = snapshot.get(FieldsKeys.members.rawValue) as? [DocumentReference] ?? []
            var readyMembers = snapshot.get(FieldsKeys.readyMembers.rawValue) as? [DocumentReference] ?? []
            let currentPlayerRef = strongSelf.db.collection(CollectionsKeys.players.rawValue).document(userId)
            if members.contains(currentPlayerRef) {
                members.removeAll(where: { $0 == currentPlayerRef })
                snapshot.reference.setData([FieldsKeys.members.rawValue: members], mergeFields: [FieldsKeys.members.rawValue], completion: { _ in handler?() })
            }
            if readyMembers.contains(currentPlayerRef) {
                readyMembers.removeAll(where: { $0 == currentPlayerRef })
                snapshot.reference.setData([FieldsKeys.readyMembers.rawValue: readyMembers], mergeFields: [FieldsKeys.readyMembers.rawValue], completion: { _ in handler?() })
            }
            if members.count == .zero {
                snapshot.reference.delete(completion: { _ in handler?() })
            }
            strongSelf.currentLobbieId = nil
            strongSelf.lastLobbieId = saveLastLobbie ? lobbieId : nil
        }
    }

    func enterInLobbie(lobbieId: String, _ handler: (() -> Void)? = nil) {
        db.collection(CollectionsKeys.lobbies.rawValue).document(lobbieId).getDocument { [weak self] snapshot, error in
            guard let strongSelf = self, let snapshot = snapshot, snapshot.exists, let userId = UserService.shared.getUserId() else {
                handler?()
                return
            }
            var members = snapshot.get(FieldsKeys.members.rawValue) as? [DocumentReference] ?? []
            var readyMembers = snapshot.get(FieldsKeys.readyMembers.rawValue) as? [DocumentReference] ?? []
            let currentPlayerRef = strongSelf.db.collection(CollectionsKeys.players.rawValue).document(userId)
            if !members.contains(currentPlayerRef) {
                members.append(currentPlayerRef)
                snapshot.reference.setData([FieldsKeys.members.rawValue: members], mergeFields: [FieldsKeys.members.rawValue], completion: { _ in handler?() })
            }
            if readyMembers.contains(currentPlayerRef) {
                readyMembers.removeAll(where: { $0 == currentPlayerRef })
                snapshot.reference.setData([FieldsKeys.readyMembers.rawValue: readyMembers], mergeFields: [FieldsKeys.readyMembers.rawValue], completion: { _ in handler?() })
            }
            strongSelf.currentLobbieId = lobbieId
        }
    }

    func createGame(fromLobbie lobbieId: String, _ handler: @escaping () -> Void) {
        db
            .collection(CollectionsKeys.developerData.rawValue)
            .document(DocumentKeys.gamesData.rawValue)
            .getDocument { [weak self] snapshot, error in
                guard let strongSelf = self,
                      let snapshotData = snapshot?.data() else {
                    handler()
                    return
                }

                let allSituations = snapshotData[FieldsKeys.situations.rawValue] as? [String] ?? []
                var allSituations50Random = Set<String>()
                while allSituations50Random.count < 2 {
                    let index = Int.random(in: 0..<allSituations.count)
                    allSituations50Random.insert(allSituations[index])
                }

                let allMemes = snapshotData[FieldsKeys.memes.rawValue] as? [String] ?? []

                strongSelf.db
                    .collection(CollectionsKeys.lobbies.rawValue)
                    .document(lobbieId)
                    .getDocument { snapshot, error in
                        guard let snapshotData = snapshot?.data(),
                              let playersRefs = snapshotData[FieldsKeys.members.rawValue] as? [DocumentReference] else {
                            handler()
                            return
                        }

                        let playersIds = playersRefs.map(\.documentID)
                        guard playersIds.first == UserService.shared.getUserId() else {
                            handler()
                            return
                        }
                        var playersValue: [[String: Any]] = []
                        var takenMemesIndexes: [Int] = []
                        for playersRef in playersRefs {
                            var hand: [String] = []
                            while hand.count < 2 {
                                let memeIndex = Int.random(in: 0..<allMemes.count)
                                if takenMemesIndexes.contains(memeIndex) { continue }
                                let newMeme = allMemes[memeIndex]
                                hand.append(newMeme)
                                takenMemesIndexes.append(memeIndex)
                            }

                            let newPlayer: [String: Any] = [
                                FieldsKeys.isOnline.rawValue: true,
                                FieldsKeys.ref.rawValue: playersRef,
                                FieldsKeys.hand.rawValue: hand
                            ]
                            playersValue.append(newPlayer)
                        }

                        let currentStep: [String: Any] = [
                            FieldsKeys.index.rawValue: 0
                        ]

                        let newGameData: [String: Any] = [
                            FieldsKeys.situations.rawValue: Array(allSituations50Random),
                            FieldsKeys.players.rawValue: playersValue,
                            FieldsKeys.currentStep.rawValue: currentStep
                        ]
                        let newGameRef = strongSelf.db
                            .collection(CollectionsKeys.games.rawValue)
                            .document()
                        let newGameId = newGameRef.documentID
                        newGameRef.setData(newGameData) { error in
                            guard error == nil else {
                                handler()
                                return
                            }

                            let newLobbieData: [String: Any] = [
                                FieldsKeys.gameId.rawValue: newGameId
                            ]
                            strongSelf.db
                                .collection(CollectionsKeys.lobbies.rawValue)
                                .document(lobbieId)
                                .setData(newLobbieData, mergeFields: [FieldsKeys.gameId.rawValue]) { error in
                                    handler()
                                }
                        }
                    }
            }
    }

    func enterLastLobbie() {
        guard let lastLobbieId = lastLobbieId else {
            return
        }
        enterInLobbie(lobbieId: lastLobbieId)
    }

    func clearLastLobbie() {
        lastLobbieId = nil
    }
}


// MARK: - Private
private extension FirestoreService {
    static func documentToLobbie(_ document: DocumentSnapshot) -> Lobbie? {
        guard let data = document.data() else { return nil }
        let id = document.documentID
        let name = data[FieldsKeys.name.rawValue] as? String ?? "Name"
        let membersRefs = data[FieldsKeys.members.rawValue] as? [DocumentReference] ?? []
        let membersPaths = membersRefs.map(\.path)
        let readyMembersRefs = data[FieldsKeys.readyMembers.rawValue] as? [DocumentReference] ?? []
        let readyMembersPaths = readyMembersRefs.map(\.path)
        let gameId = data[FieldsKeys.gameId.rawValue] as? String
        return Lobbie(id: id, name: name, membersPaths: membersPaths, readyMembersPaths: readyMembersPaths, gameId: gameId)
    }
}


fileprivate enum CollectionsKeys: String {
    case lobbies
    case players
    case games
    case developerData
}

fileprivate enum DocumentKeys: String {
    case gamesData
}

fileprivate enum FieldsKeys: String {
    case name
    case members
    case readyMembers
    case situations
    case memes
    case players
    case hand
    case isOnline
    case ref
    case steppedPlayers
    case card
    case index
    case currentStep
    case gameId
}
