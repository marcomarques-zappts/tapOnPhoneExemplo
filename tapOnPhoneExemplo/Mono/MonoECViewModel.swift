import Foundation
import TapOnPhone
import Combine
@MainActor
class MonoECViewModel: ObservableObject {
    @Published var companyDocument: String = ""
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var storeCode: String = ""

    @Published var isLoading: Bool = false
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var authResult: MonoECAuthResult?

    var canAuthenticate: Bool {
        !companyDocument.isEmpty && !username.isEmpty && !password.isEmpty
    }

    func authenticate() async {
        isLoading = true
        defer { isLoading = false }

        let params = MonoECAuthParameters(
            companyDocument: companyDocument,
            username: username,
            password: password,
            storeCode: storeCode.isEmpty ? nil : storeCode
        )

        let result = await TapOnPhoneSDK.operations.authenticateMonoEC(params)
        authResult = result
        alertTitle = result.isSuccessful ? "Sucesso" : "Erro de autenticação"
        alertMessage = result.message
        showAlert = true
    }

    func clearForm() {
        companyDocument = ""
        username = ""
        password = ""
        storeCode = ""
        authResult = nil
    }
}
