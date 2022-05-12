//
//  User.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 12.05.2022.
//

import Foundation

final class UserService {
    private init() {}
    static let shared = UserService()


    func getUserId() -> String? {
        UserDefaults.standard.string(forKey: UserDefaultsKeys.userId.rawValue)
    }

    func setUserId(_ newUserId: String) {
        UserDefaults.standard.set(newUserId, forKey: UserDefaultsKeys.userId.rawValue)
    }
}


private enum UserDefaultsKeys: String {
    case userId
}
