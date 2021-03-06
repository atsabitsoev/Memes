//
//  KeyboardNotificationsObserver.swift
//  WhatDoYouMeme
//
//  Created by Ацамаз Бицоев on 12.05.2022.
//

import UIKit

/// An observer for `UIKeyboard` notifications that provides a safe and convenient interface.
public class KeyboardNotificationsObserver {

    /// A keyboard notification type.
    public enum NotificationType {
        /// Corresponds to `UIKeyboardWillShowNotification`.
        case willShow
        /// Corresponds to `UIKeyboardDidShowNotification`.
        case didShow
        /// Corresponds to `UIKeyboardWillHideNotification`.
        case willHide
        /// Corresponds to `UIKeyboardDidHideNotification`.
        case didHide
        /// Corresponds to `UIKeyboardWillChangeFrameNotification`.
        case willChangeFrame
        /// Corresponds to `UIKeyboardDidChangeFrameNotification`.
        case didChangeFrame

        /// A name of a notification that corresponds to this notification type.
        public var name: Notification.Name {
            switch self {
            case .willShow: return UIResponder.keyboardWillShowNotification
            case .didShow: return UIResponder.keyboardDidShowNotification
            case .willHide: return UIResponder.keyboardWillHideNotification
            case .didHide: return UIResponder.keyboardDidHideNotification
            case .willChangeFrame: return UIResponder.keyboardWillChangeFrameNotification
            case .didChangeFrame: return UIResponder.keyboardDidChangeFrameNotification
            }
        }

        /// Creates the notification type from a notification name.
        public init?(name: Notification.Name) {
            switch name {
            case UIResponder.keyboardWillShowNotification: self = .willShow
            case UIResponder.keyboardDidShowNotification : self = .didShow
            case UIResponder.keyboardWillHideNotification: self = .willHide
            case UIResponder.keyboardDidHideNotification: self = .didHide
            case UIResponder.keyboardWillChangeFrameNotification: self = .willChangeFrame
            case UIResponder.keyboardDidChangeFrameNotification: self = .didChangeFrame
            default:
                return nil
            }
        }
    }

    /// Represents info about keyboard extracted from notification's `userInfo`.
    public struct UserInfo {

        /// The type of a notification.
        public let notificationType: NotificationType

        /// The start frame of the keyboard in screen coordinates.
        /// Corresponds to `UIKeyboardFrameBeginUserInfoKey`.
        public let beginFrame: CGRect

        /// The end frame of the keyboard in screen coordinates.
        /// Corresponds to `UIKeyboardFrameEndUserInfoKey`.
        public let endFrame: CGRect

        /// Defines how the keyboard will be animated onto or off the screen.
        /// Corresponds to `UIKeyboardAnimationCurveUserInfoKey`.
        public let animationCurve: UIView.AnimationCurve

        /// The duration of the animation in seconds.
        /// Corresponds to `UIKeyboardAnimationDurationUserInfoKey`.
        public let animationDuration: TimeInterval

        /// Shows whether the keyboard belongs to the current app.
        /// Corresponds to `UIKeyboardIsLocalUserInfoKey`.
        public let isLocal: Bool

        /// Options for animating constructed from `animationCurve` property.
        public var animationOptions: UIView.AnimationOptions {
            return UIView.AnimationOptions(rawValue: UInt(animationCurve.rawValue << 16))
        }

        /// Creates an instance of `UserInfo` using `userInfo` from a notification object.
        public init(info: [AnyHashable: Any]?, notificationType: NotificationType) {
            self.notificationType = notificationType
            self.beginFrame = (info?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero
            self.endFrame = (info?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero
            self.animationCurve = UIView.AnimationCurve(rawValue: info?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int ?? 0) ?? .easeInOut
            self.animationDuration = TimeInterval(info?[UIResponder.keyboardAnimationDurationUserInfoKey] as? CGFloat ?? 0.0)
            self.isLocal = info?[UIResponder.keyboardIsLocalUserInfoKey] as? Bool ?? false
        }
    }

    /// A callback for a `willShow` notification.
    public var onWillShow: ((UserInfo) -> Void)? {
        didSet {
            handleClosureDidSet(old: oldValue, new: onWillShow, type: .willShow)
        }
    }

    /// A callback for a `didShow` notification.
    public var onDidShow: ((UserInfo) -> Void)? {
        didSet {
            handleClosureDidSet(old: oldValue, new: onDidShow, type: .didShow)
        }
    }

    /// A callback for a `willHide` notification.
    public var onWillHide: ((UserInfo) -> Void)? {
        didSet {
            handleClosureDidSet(old: oldValue, new: onWillHide, type: .willHide)
        }
    }

    /// A callback for a `didHide` notification.
    public var onDidHide: ((UserInfo) -> Void)? {
        didSet {
            handleClosureDidSet(old: oldValue, new: onDidHide, type: .didHide)
        }
    }

    /// A callback for a `willChangeFrame` notification.
    public var onWillChangeFrame: ((UserInfo) -> Void)? {
        didSet {
            handleClosureDidSet(old: oldValue, new: onWillChangeFrame, type: .willChangeFrame)
        }
    }

    /// A callback for a `didChangeFrame` notification.
    public var onDidChangeFrame: ((UserInfo) -> Void)? {
        didSet {
            handleClosureDidSet(old: oldValue, new: onDidChangeFrame, type: .didChangeFrame)
        }
    }

    public init() {}

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func handleClosureDidSet(old: ((UserInfo) -> Void)?, new: ((UserInfo) -> Void)?, type: NotificationType) {
        switch (old, new) {
        case (nil, nil):
            break
        case (_, nil):
            removeObserver(for: type)
        case (nil, _):
            addObserver(for: type)
        case (_, _):
            removeObserver(for: type)
            addObserver(for: type)
        }
    }

    private func addObserver(for notificationType: NotificationType) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotification(_:)), name: notificationType.name, object: nil)
    }

    private func removeObserver(for notificationType: NotificationType) {
        NotificationCenter.default.removeObserver(self, name: notificationType.name, object: nil)
    }

    @objc private func keyboardNotification(_ notification: Notification) {
        if let type = NotificationType(name: notification.name) {
            let info = UserInfo(info: notification.userInfo, notificationType: type)
            switch type {
            case .willShow: onWillShow?(info)
            case .didShow: onDidShow?(info)
            case .willHide: onWillHide?(info)
            case .didHide: onDidHide?(info)
            case .willChangeFrame: onWillChangeFrame?(info)
            case .didChangeFrame: onDidChangeFrame?(info)
            }
        }
    }
}
