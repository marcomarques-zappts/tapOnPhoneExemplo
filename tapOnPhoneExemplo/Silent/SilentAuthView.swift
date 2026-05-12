import SwiftUI

struct SilentAuthView: View {
    @EnvironmentObject private var credentials: CredentialsStore
    @StateObject private var viewModel = SilentAuthViewModel()

    var body: some View {
        Form {
            if !credentials.isConfigured {
                Section {
                    Label("Configure as credenciais antes de autenticar.", systemImage: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.footnote)
                }
            }

            Section("Estabelecimento") {
                LabeledRow("CNPJ/CPF") {
                    Text(credentials.document.isEmpty ? "-" : credentials.document)
                        .foregroundColor(.secondary)
                }
                LabeledRow("Bundle ID") {
                    Text(credentials.bundleIdentifier.isEmpty ? "-" : credentials.bundleIdentifier)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }

            Section("Dispositivo (opcional)") {
                LabeledRow("Nome") {
                    TextField("Opcional", text: $viewModel.deviceName)
                        .multilineTextAlignment(.trailing)
                }
                LabeledRow("Apelido") {
                    TextField("Opcional", text: $viewModel.nickName)
                        .multilineTextAlignment(.trailing)
                }
            }

            Section {
                Button {
                    Task { await viewModel.authenticate(using: credentials) }
                } label: {
                    HStack {
                        Spacer()
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Autenticar (Silent Login)")
                                .bold()
                        }
                        Spacer()
                    }
                }
                .disabled(viewModel.isLoading || !credentials.isConfigured)

                if viewModel.isAuthenticated {
                    Button {
                        Task { await viewModel.refreshToken(using: credentials) }
                    } label: {
                        HStack {
                            Spacer()
                            Text("Renovar Token")
                            Spacer()
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }

            if viewModel.isAuthenticated {
                Section {
                    Label("Autenticado com sucesso", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
        }
        .navigationTitle("Autenticação")
        .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}

#Preview {
    NavigationView {
        SilentAuthView()
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
