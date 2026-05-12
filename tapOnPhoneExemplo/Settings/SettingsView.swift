import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var credentials: CredentialsStore

    @State private var document: String = ""
    @State private var bundleIdentifier: String = ""
    @State private var ssoUsername: String = ""
    @State private var ssoPassword: String = ""
    @State private var baseURL: String = ""
    @State private var showSavedAlert = false

    var body: some View {
        Form {
            if !credentials.isConfigured {
                Section {
                    Label("Preencha as credenciais antes de autenticar.", systemImage: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.footnote)
                }
            }

            Section("Ambiente") {
                LabeledRow("Base URL") {
                    TextField("https://api.exemplo.com.br", text: $baseURL)
                        .multilineTextAlignment(.trailing)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                }
            }

            Section("Credenciais SSO") {
                LabeledRow("Usuário") {
                    TextField("client-id", text: $ssoUsername)
                        .multilineTextAlignment(.trailing)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                LabeledRow("Senha") {
                    SecureField("client-secret", text: $ssoPassword)
                        .multilineTextAlignment(.trailing)
                }
            }

            Section("Estabelecimento") {
                LabeledRow("CNPJ/CPF") {
                    TextField("00000000000000", text: $document)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                }
                LabeledRow("Bundle ID") {
                    TextField("br.com.empresa.app", text: $bundleIdentifier)
                        .multilineTextAlignment(.trailing)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
            }

            Section {
                Button {
                    save()
                } label: {
                    HStack {
                        Spacer()
                        Text("Salvar")
                            .bold()
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Configurações")
        .onAppear { loadFromStore() }
        .alert("Salvo", isPresented: $showSavedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("As credenciais foram salvas com sucesso.")
        }
    }

    private func loadFromStore() {
        document         = credentials.document
        bundleIdentifier = credentials.bundleIdentifier
        ssoUsername      = credentials.ssoUsername
        ssoPassword      = credentials.ssoPassword
        baseURL          = credentials.baseURL
    }

    private func save() {
        credentials.document         = document
        credentials.bundleIdentifier = bundleIdentifier
        credentials.ssoUsername      = ssoUsername
        credentials.ssoPassword      = ssoPassword
        credentials.baseURL          = baseURL
        showSavedAlert = true
    }
}

#Preview {
    NavigationView {
        SettingsView()
            .environmentObject(CredentialsStore())
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
