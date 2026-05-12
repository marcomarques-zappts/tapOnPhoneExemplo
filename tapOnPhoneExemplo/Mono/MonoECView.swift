import SwiftUI
import TapOnPhone

struct MonoECView: View {
    @StateObject private var viewModel = MonoECViewModel()

    var body: some View {
        Form {
            Section {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Apenas para certificações internas. Use Silent Login em produção.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Section("Credenciais") {
                LabeledRow("CNPJ da empresa") {
                    TextField("Obrigatório", text: $viewModel.companyDocument)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                }
                LabeledRow("Usuário") {
                    TextField("Obrigatório", text: $viewModel.username)
                        .multilineTextAlignment(.trailing)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                LabeledRow("Senha") {
                    SecureField("Obrigatório", text: $viewModel.password)
                        .multilineTextAlignment(.trailing)
                }
                LabeledRow("Código da loja") {
                    TextField("Opcional", text: $viewModel.storeCode)
                        .multilineTextAlignment(.trailing)
                }
            }

            Section {
                Button {
                    Task { await viewModel.authenticate() }
                } label: {
                    HStack {
                        Spacer()
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Autenticar (MonoEC)")
                                .bold()
                        }
                        Spacer()
                    }
                }
                .disabled(!viewModel.canAuthenticate || viewModel.isLoading)

                Button("Limpar", role: .destructive) {
                    viewModel.clearForm()
                }
            }

            if let result = viewModel.authResult {
                Section("Resultado") {
                    LabeledRow("Status") {
                        Text(result.isSuccessful ? "Sucesso" : "Falha")
                            .foregroundColor(result.isSuccessful ? .green : .red)
                    }
                    LabeledRow("Código") { Text("\(result.statusCode)") }
                    if let config = result.configuration {
                        LabeledRow("Terminal") { Text(config.terminalCode) }
                        LabeledRow("Loja") { Text(config.storeName) }
                    }
                }
            }
        }
        .navigationTitle("Auth MonoEC")
        .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}

#Preview {
    NavigationView {
        MonoECView()
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
