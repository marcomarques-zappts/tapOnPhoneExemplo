import Foundation
import Combine

class CredentialsStore: ObservableObject {

    @Published var document: String {
        didSet { UserDefaults.standard.set(document, forKey: "cred_document") }
    }
    @Published var bundleIdentifier: String {
        didSet { UserDefaults.standard.set(bundleIdentifier, forKey: "cred_bundleId") }
    }
    @Published var ssoUsername: String {
        didSet { UserDefaults.standard.set(ssoUsername, forKey: "cred_ssoUsername") }
    }
    @Published var ssoPassword: String {
        didSet { UserDefaults.standard.set(ssoPassword, forKey: "cred_ssoPassword") }
    }
    @Published var baseURL: String {
        didSet { UserDefaults.standard.set(baseURL, forKey: "cred_baseURL") }
    }

    var isConfigured: Bool {
        !document.isEmpty && !bundleIdentifier.isEmpty &&
        !ssoUsername.isEmpty && !ssoPassword.isEmpty && !baseURL.isEmpty
    }

    init() {
        let ud = UserDefaults.standard
        document        = ud.string(forKey: "cred_document")     ?? ""
        bundleIdentifier = ud.string(forKey: "cred_bundleId")   ?? ""
        ssoUsername     = ud.string(forKey: "cred_ssoUsername") ?? ""
        ssoPassword     = ud.string(forKey: "cred_ssoPassword") ?? ""
        baseURL         = ud.string(forKey: "cred_baseURL")     ?? ""
    }
}
