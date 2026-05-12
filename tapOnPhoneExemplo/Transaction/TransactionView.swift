import SwiftUI
import TapOnPhone

struct TransactionView: View {
    @StateObject private var viewModel = TransactionViewModel()

    var body: some View {
        ZStack {
        Form {
            Section("Valor") {
                HStack {
                    Text("R$")
                    TextField("0,00", text: $viewModel.amountText)
                        .keyboardType(.decimalPad)
                }
            }

            Section("Tipo de crédito") {
                Picker("Parcelamento", selection: $viewModel.installmentType) {
                    Text("À vista").tag(InstallmentType.upfront)
                    Text("Loja").tag(InstallmentType.store)
                    Text("Administrativo").tag(InstallmentType.administrative)
                    Text("Parcelado lojista").tag(InstallmentType.merchantInstallment)
                }
                .pickerStyle(.menu)

                if viewModel.installmentType != .upfront {
                    Picker("Parcelas", selection: $viewModel.installmentNumber) {
                        ForEach(viewModel.installmentOptions, id: \.self) { n in
                            Text("\(n)x").tag(n)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }

            Section("Pagamento") {
                Button {
                    Task { await viewModel.executeDebit() }
                } label: {
                    HStack {
                        Spacer()
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Label("Pagar com Débito", systemImage: "creditcard")
                        }
                        Spacer()
                    }
                }
                .disabled(!viewModel.canPay || viewModel.isLoading)

                Button {
                    Task { await viewModel.executeCredit() }
                } label: {
                    HStack {
                        Spacer()
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Label("Pagar com Crédito", systemImage: "creditcard.fill")
                        }
                        Spacer()
                    }
                }
                .disabled(!viewModel.canPay || viewModel.isLoading)
            }

            Section("Pagamento NFC") {
                Button {
                    Task { await viewModel.executeDebitNFC() }
                } label: {
                    HStack {
                        Spacer()
                        Label("Pagar com Débito NFC", systemImage: "wave.3.right")
                        Spacer()
                    }
                }
                .disabled(!viewModel.canPay || viewModel.isLoading)

                Button {
                    Task { await viewModel.executeCreditNFC() }
                } label: {
                    HStack {
                        Spacer()
                        Label("Pagar com Crédito NFC", systemImage: "wave.3.right.circle.fill")
                        Spacer()
                    }
                }
                .disabled(!viewModel.canPay || viewModel.isLoading)
            }

            if let result = viewModel.lastResult {
                Section("Último resultado") {
                    LabeledRow("Status") {
                        Text(statusLabel(result.status))
                            .foregroundColor(statusColor(result.status))
                            .bold()
                    }
                    LabeledRow("Valor") { Text(result.formattedAmount) }
                    if !result.ctf.authorizationCode.isEmpty {
                        LabeledRow("Autorização") { Text(result.ctf.authorizationCode) }
                    }
                    if !result.ctf.maskedPan.isEmpty {
                        LabeledRow("Cartão") { Text(result.ctf.maskedPan) }
                    }
                    if !result.ctf.brandName.isEmpty {
                        LabeledRow("Bandeira") { Text(result.ctf.brandName) }
                    }
                    if !result.ctf.nsuHost.isEmpty {
                        LabeledRow("NSU Host") { Text(result.ctf.nsuHost) }
                    }
                    LabeledRow("Código retorno") { Text(result.returnCode) }
                }
            }
        }

        if viewModel.showNFCOverlay {
            NFCPaymentOverlay(amount: viewModel.formattedAmountText)
                .ignoresSafeArea()
        }
        }
        .navigationTitle("Transações")
        .animation(.easeInOut(duration: 0.25), value: viewModel.showNFCOverlay)
        .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.alertMessage)
        }
    }

    private func statusLabel(_ status: CardPaymentStatus) -> String {
        switch status {
        case .approved: return "Aprovada"
        case .denied: return "Negada"
        case .cancelled: return "Cancelada"
        case .error: return "Erro"
        case .unknown: return "Desconhecido"
        }
    }

    private func statusColor(_ status: CardPaymentStatus) -> Color {
        switch status {
        case .approved: return .green
        case .denied, .error: return .red
        case .cancelled: return .orange
        case .unknown: return .secondary
        }
    }
}

private struct LabeledRow<Content: View>: View {
    let label: String
    @ViewBuilder let content: () -> Content

    init(_ label: String, @ViewBuilder content: @escaping () -> Content) {
        self.label = label
        self.content = content
    }

    var body: some View {
        if #available(iOS 16.0, *) {
            LabeledContent(label, content: content)
        } else {
            HStack {
                Text(label)
                Spacer()
                content()
            }
        }
    }
}
