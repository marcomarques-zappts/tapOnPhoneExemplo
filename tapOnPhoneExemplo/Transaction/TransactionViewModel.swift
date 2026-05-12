import Foundation
import TapOnPhone
import Combine

@MainActor
class TransactionViewModel: ObservableObject {
    @Published var amountText: String = ""
    @Published var installmentType: InstallmentType = .upfront
    @Published var installmentNumber: Int = 1

    @Published var isLoading: Bool = false
    @Published var showNFCOverlay: Bool = false
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var lastResult: CardPaymentResult?

    var formattedAmountText: String {
        "R$ \(amountText)"
    }

    var amount: Decimal {
        Decimal(string: amountText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    var canPay: Bool {
        amount > 0
    }

    var installmentOptions: [Int] {
        switch installmentType {
        case .upfront: return [0]
        case .store, .administrative, .merchantInstallment: return Array(2...12)
        }
    }

    func executeDebit() async {
        await runTransaction {
            try await TapOnPhoneSDK.operations.executeDebitCardPayment(value: self.amount)
        }
    }

    func executeCredit() async {
        let number = installmentType == .upfront ? 0 : installmentNumber
        await runTransaction {
            try await TapOnPhoneSDK.operations.executeCreditCardPayment(
                value: self.amount,
                installmentType: self.installmentType,
                installmentNumber: number
            )
        }
    }

    func executeDebitNFC() async {
        showNFCOverlay = true
        // Cede o ciclo do MainActor para o SwiftUI renderizar o overlay antes de iniciar
        await Task.yield()
        await runTransaction {
            try await TapOnPhoneSDK.operations.executeDebitCardPayment(value: self.amount)
        }
        showNFCOverlay = false
    }

    func executeCreditNFC() async {
        showNFCOverlay = true
        await Task.yield()
        let number = installmentType == .upfront ? 0 : installmentNumber
        await runTransaction {
            try await TapOnPhoneSDK.operations.executeCreditCardPayment(
                value: self.amount,
                installmentType: self.installmentType,
                installmentNumber: number
            )
        }
        showNFCOverlay = false
    }

    private func runTransaction(_ operation: @escaping () async throws -> CardPaymentResult) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await operation()
            lastResult = result
            alertTitle = result.status == .approved ? "Transação aprovada" : "Transação não aprovada"
            alertMessage = buildResultMessage(result)
        
        } catch {
            alertTitle = "Erro"
            alertMessage = error.localizedDescription
        }
        showAlert = true
    }

    private func buildResultMessage(_ result: CardPaymentResult) -> String {
        var lines: [String] = []
        lines.append("Status: \(result.status)")
        lines.append("Valor: \(result.formattedAmount)")
        if !result.ctf.authorizationCode.isEmpty {
            lines.append("Autorização: \(result.ctf.authorizationCode)")
        }
        if !result.ctf.maskedPan.isEmpty {
            lines.append("Cartão: \(result.ctf.maskedPan)")
        }
        if !result.ctf.brandName.isEmpty {
            lines.append("Bandeira: \(result.ctf.brandName)")
        }
        return lines.joined(separator: "\n")
    }
}
