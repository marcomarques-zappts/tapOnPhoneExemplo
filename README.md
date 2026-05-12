# TapOnPhone — Sample App iOS

App de exemplo em SwiftUI demonstrando a integração com o SDK **TapOnPhone** (Auttar/Getnet) para pagamentos por aproximação (Tap to Pay on iPhone).

## Funcionalidades

- **Silent Login** — autenticação automática via SSO + App Token, sem interação do usuário
- **Pagamento Débito/Crédito** — transações com parcelamento via terminal TEF
- **Pagamento NFC** — overlay dedicado para leitura de cartão por aproximação
- **MonoEC** — autenticação alternativa para ambiente de certificação
- **Configurações** — tela para inserir credenciais do ambiente sem hardcode

## Requisitos

- Xcode 15+
- iOS 15.0+
- iPhone físico (NFC não funciona em simulador)
- Provisioning profile com entitlement `com.apple.developer.proximity-reader.payment.acceptance`
- Credenciais de acesso ao ambiente Auttar (SSO + CNPJ)

## Configuração

Na primeira execução, acesse a aba **Configurações** (ícone de engrenagem) e preencha:

| Campo | Descrição |
|---|---|
| Base URL | URL do ambiente (ex: `https://api-hti.auttar.com.br`) |
| Usuário SSO | Client ID fornecido pela Auttar |
| Senha SSO | Client Secret fornecido pela Auttar |
| CNPJ/CPF | Documento do estabelecimento |
| Bundle ID | Bundle identifier registrado (`br.com.auttar.app.getTap`) |

As credenciais são salvas localmente via `UserDefaults`.

## Fluxo de autenticação

```
1. requestAccessToken  →  POST /v1/tef-embarcado/oauth/token
                           Basic Auth (ssoUsername:ssoPassword)
                           Body: grant_type=client_credentials

2. requestAppToken     →  POST /v1/tef-embarcado/top-auth-adp/app-token
                           Bearer {accessToken}
                           Body: { document, package_name }

3. authenticationSilentLogin(SilentLoginParams)
                       →  SDK autentica o terminal
```

## Estrutura do projeto

```
tapOnPhoneExemplo/
├── AppCredentials.swift          # Substituído por CredentialsStore
├── ContentView.swift             # TabView principal (4 abas)
├── SDK/
│   ├── SDKDelegateHandler.swift  # Delegates de mensagem e UI do SDK
│   └── SDKMessageOverlay.swift   # Overlay de mensagens do SDK
├── Settings/
│   ├── CredentialsStore.swift    # Persistência das credenciais (UserDefaults)
│   └── SettingsView.swift        # Tela de configuração
├── Silent/
│   ├── SilentAuthService.swift   # Chamadas HTTP para SSO e App Token
│   ├── SilentAuthViewModel.swift # Orquestra o fluxo de autenticação
│   └── SilentAuthView.swift      # Tela de autenticação
├── Transaction/
│   ├── TransactionViewModel.swift
│   ├── TransactionView.swift     # Tela de transações
│   └── NFCPaymentOverlay.swift   # Overlay fullscreen para pagamento NFC
└── Mono/
    ├── MonoECViewModel.swift
    └── MonoECView.swift          # Tela de autenticação MonoEC
```

## Entitlement necessário

```xml
<key>com.apple.developer.proximity-reader.payment.acceptance</key>
<true/>
```

Este entitlement exige aprovação prévia da Apple e deve ser provisionado
pela equipe responsável pelo Bundle ID registrado.

## SDK

O projeto utiliza `TapOnPhoneHTI.xcframework` (ambiente HTI).
Para o ambiente de produção, substitua pelo framework correspondente e
atualize a Base URL nas Configurações do app.
