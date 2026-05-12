import Foundation
import TapOnPhone
import Combine

@MainActor
class SilentAuthViewModel: ObservableObject {
    @Published var deviceName: String = ""
    @Published var nickName: String = ""

    @Published var isLoading: Bool = false
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var isAuthenticated: Bool = false

    func authenticate(using credentials: CredentialsStore) async {
        isLoading = true
        defer { isLoading = false }

        let service = SilentAuthService(baseURL: credentials.baseURL)

        do {
            let ssoResponse = try await service.requestAccessToken(
                ssoUsername: credentials.ssoUsername,
                ssoPassword: credentials.ssoPassword
            )

            let appToken = try await service.requestAppToken(
                accessToken: ssoResponse.accessToken,
                document: credentials.document,
                bundleIdentifier: credentials.bundleIdentifier
            )

            let documentBase64 = Data(credentials.document.utf8).base64EncodedString()

            let tokens = AuthenticationTokens(
                ssoToken: ssoResponse.accessToken,
                expiresIn: ssoResponse.expiresIn,
                creationDate: Date()
            )

            let params = SilentLoginParams(
                tokens: tokens,
                appToken: appToken,
                packageName: credentials.bundleIdentifier,
                document: documentBase64,
                deviceName: deviceName.isEmpty ? nil : deviceName,
                nickName: nickName.isEmpty ? nil : nickName
            )

            let result = await TapOnPhoneSDK.operations.authenticationSilentLogin(params)

            isAuthenticated = result.isSuccessful
            alertTitle = result.isSuccessful ? "Autenticação OK" : "Erro"
            alertMessage = result.message
            showAlert = true

            #if DEBUG
            if result.isSuccessful, let config = result.configuration {
                print("✅ Silent Login bem-sucedido!")
                print("   Terminal: \(config.codeTerm ?? "-")")
                print("   Loja: \(config.storeName ?? "-")")
            } else {
                print("❌ Silent Login falhou: \(result.message)")
            }
            #endif

        } catch {
            alertTitle = "Erro"
            alertMessage = error.localizedDescription
            showAlert = true

            #if DEBUG
            print("❌ Erro no fluxo de autenticação: \(error)")
            #endif
        }
    }

    func refreshToken(using credentials: CredentialsStore) async {
        isLoading = true
        defer { isLoading = false }

        let service = SilentAuthService(baseURL: credentials.baseURL)

        do {
            let ssoResponse = try await service.requestAccessToken(
                ssoUsername: credentials.ssoUsername,
                ssoPassword: credentials.ssoPassword
            )

            let tokens = AuthenticationTokens(
                ssoToken: ssoResponse.accessToken,
                expiresIn: ssoResponse.expiresIn,
                creationDate: Date()
            )

            let success = TapOnPhoneSDK.operations.setAccessToken(tokens)
            alertTitle = success ? "Token atualizado" : "Falha ao atualizar token"
            alertMessage = success ? "O accessToken foi renovado com sucesso." : "Não foi possível atualizar o token."
            showAlert = true

        } catch {
            alertTitle = "Erro ao renovar token"
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }
}
