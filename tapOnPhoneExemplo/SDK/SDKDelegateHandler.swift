import Foundation
import SwiftUI
import TapOnPhone
import Combine

@MainActor
class SDKDelegateHandler: ObservableObject, TapOnPhoneMessageDelegate, TapOnPhoneUIDelegate {
    @Published var currentMessage: String = ""
    @Published var showMessage: Bool = false
    @Published var isProcessing: Bool = false

    // Keyboard input continuation
    private var keyboardContinuation: CheckedContinuation<String?, Never>?
    @Published var keyboardRequest: KeyboardRequest?
    @Published var keyboardInput: String = ""
    @Published var showKeyboard: Bool = false

    // Menu selection continuation
    private var menuContinuation: CheckedContinuation<String?, Never>?
    @Published var menuRequest: MenuRequest?
    @Published var showMenu: Bool = false

    // Image display continuation
    private var imageContinuation: CheckedContinuation<Int, Never>?
    @Published var imageRequest: ImageRequest?
    @Published var showImage: Bool = false

    init() {}

    func setup() {
        TapOnPhoneSDK.messageDelegate = self
        TapOnPhoneSDK.uiDelegate = self
    }

    // MARK: - TapOnPhoneMessageDelegate

    nonisolated func tapOnPhoneDidReceiveMessage(_ message: TapOnPhoneMessage) {
        Task { @MainActor in
            self.currentMessage = message.text
            self.showMessage = true
            if message.sleepSeconds > 0 {
                try? await Task.sleep(nanoseconds: UInt64(message.sleepSeconds * 1_000_000_000))
                self.showMessage = false
            }
        }
    }

    // MARK: - TapOnPhoneUIDelegate

    nonisolated func requestKeyboard(_ request: KeyboardRequest) async -> String? {
        await MainActor.run {
            self.keyboardRequest = request
            self.keyboardInput = ""
            self.showKeyboard = true
        }
        return await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.keyboardContinuation = continuation
            }
        }
    }

    nonisolated func showMenu(_ request: MenuRequest) async -> String? {
        await MainActor.run {
            self.menuRequest = request
            self.showMenu = true
        }
        return await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.menuContinuation = continuation
            }
        }
    }

    nonisolated func showMessage(_ request: MessageRequest) {
        Task { @MainActor in
            self.currentMessage = request.message
            self.showMessage = true
        }
    }

    nonisolated func showImage(_ request: ImageRequest) async -> Int {
        await MainActor.run {
            self.imageRequest = request
            self.showImage = true
        }
        return await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.imageContinuation = continuation
            }
        }
    }

    // MARK: - Response helpers

    func submitKeyboard() {
        showKeyboard = false
        let value = keyboardInput
        keyboardContinuation?.resume(returning: value.isEmpty ? nil : value)
        keyboardContinuation = nil
    }

    func cancelKeyboard() {
        showKeyboard = false
        keyboardContinuation?.resume(returning: nil)
        keyboardContinuation = nil
    }

    func selectMenuOption(_ option: String) {
        showMenu = false
        menuContinuation?.resume(returning: option)
        menuContinuation = nil
    }

    func dismissImage(result: Int = 0) {
        showImage = false
        imageContinuation?.resume(returning: result)
        imageContinuation = nil
    }
}
