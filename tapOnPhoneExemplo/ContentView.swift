import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var sdkHandler: SDKDelegateHandler

    var body: some View {
        TabView {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    SilentAuthView()
                }
                .tabItem {
                    Label("Autenticação", systemImage: "lock.shield")
                }
            } else {
                NavigationView {
                    SilentAuthView()
                }
                .tabItem {
                    Label("Autenticação", systemImage: "lock.shield")
                }
            }

            if #available(iOS 16.0, *) {
                NavigationStack {
                    TransactionView()
                }
                .tabItem {
                    Label("Transações", systemImage: "creditcard.and.123")
                }
            } else {
                NavigationView {
                    TransactionView()
                }
                .tabItem {
                    Label("Transações", systemImage: "creditcard.and.123")
                }
            }

            if #available(iOS 16.0, *) {
                NavigationStack {
                    MonoECView()
                }
                .tabItem {
                    Label("MonoEC", systemImage: "building.2")
                }
            } else {
                NavigationView {
                    MonoECView()
                }
                .tabItem {
                    Label("MonoEC", systemImage: "building.2")
                }
            }

            if #available(iOS 16.0, *) {
                NavigationStack {
                    SettingsView()
                }
                .tabItem {
                    Label("Configurações", systemImage: "gear")
                }
            } else {
                NavigationView {
                    SettingsView()
                }
                .tabItem {
                    Label("Configurações", systemImage: "gear")
                }
            }
        }
        .overlay { SDKMessageOverlay(handler: sdkHandler) }
        .task { sdkHandler.setup() }
    }
}
