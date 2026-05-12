//
//  tapOnPhoneExemploApp.swift
//  tapOnPhoneExemplo
//
//  Created by Marco Marques on 20/04/26.
//

import SwiftUI

@main
struct tapOnPhoneExemploApp: App {
    @StateObject private var sdkHandler = SDKDelegateHandler()
    @StateObject private var credentials = CredentialsStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sdkHandler)
                .environmentObject(credentials)
        }
    }
}
