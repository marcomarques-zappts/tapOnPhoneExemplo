//
//  SilentAuthService.swift
//  tapOnPhoneExemplo
//
//  Created by Marco Marques on 23/04/26.
//
import TapOnPhone
import Foundation

protocol SilentAuthServiceProtocol {
    func requestAccessToken(ssoUsername: String, ssoPassword: String) async throws -> SSOResponse
    func requestAppToken(accessToken: String, document: String, bundleIdentifier: String) async throws -> String
}

private struct AppTokenRequest: Encodable {
    let document: String
    let bundleIdentifier: String

    enum CodingKeys: String, CodingKey {
        case document
        case bundleIdentifier = "package_name"
    }
}

private struct AppTokenEnvelope: Decodable {
    let details: Details

    struct Details: Decodable {
        let token: String
    }
}

class SilentAuthService: SilentAuthServiceProtocol {

    private let baseURL: String

    init(baseURL: String) {
        self.baseURL = baseURL
    }

    func requestAccessToken(ssoUsername: String, ssoPassword: String) async throws -> SSOResponse {
        let urlString = "\(baseURL)/v1/tef-embarcado/oauth/token"

        guard let url = URL(string: urlString) else {
            throw AuthenticationError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let credentials = "\(ssoUsername):\(ssoPassword)"
        guard let credentialsData = credentials.data(using: .utf8) else {
            throw AuthenticationError.invalidCredentials
        }

        let base64Credentials = credentialsData.base64EncodedString()
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.httpBody = "grant_type=client_credentials".data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthenticationError.invalidResponse
        }

        #if DEBUG
        if let responseString = String(data: data, encoding: .utf8) {
            print("---- SSO Response (\(httpResponse.statusCode)): \(responseString)")
        }
        #endif

        switch httpResponse.statusCode {
        case 200, 201:
            return try JSONDecoder().decode(SSOResponse.self, from: data)
        case 401, 403:
            throw AuthenticationError.invalidCredentials
        case 500:
            throw AuthenticationError.serverError("Internal Server Error")
        default:
            throw AuthenticationError.serverError("HTTP Status: \(httpResponse.statusCode)")
        }
    }

    func requestAppToken(accessToken: String, document: String, bundleIdentifier: String) async throws -> String {
        let urlString = "\(baseURL)/v1/tef-embarcado/top-auth-adp/app-token"

        guard let url = URL(string: urlString) else {
            throw AuthenticationError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let body = AppTokenRequest(document: document, bundleIdentifier: bundleIdentifier)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthenticationError.invalidResponse
        }

        #if DEBUG
        if let responseString = String(data: data, encoding: .utf8) {
            print("---- APP Token Response (\(httpResponse.statusCode)): \(responseString)")
        }
        #endif

        switch httpResponse.statusCode {
        case 200, 201:
            let envelope = try JSONDecoder().decode(AppTokenEnvelope.self, from: data)
            guard !envelope.details.token.isEmpty else {
                throw AuthenticationError.tokenExpired
            }
            return envelope.details.token
        case 401, 403:
            throw AuthenticationError.invalidCredentials
        case 500:
            throw AuthenticationError.serverError("Internal Server Error")
        default:
            let body = String(data: data, encoding: .utf8) ?? ""
            throw AuthenticationError.serverError("HTTP Status: \(httpResponse.statusCode) - \(body)")
        }
    }
}
