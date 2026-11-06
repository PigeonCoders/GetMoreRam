//
//  Shared.swift
//  GetMoreRam
//
//  Created by s s on 2025/3/15.
//
import SwiftUI
import StosSign_API
import StosSign_Auth
import StosSign_Common

class AlertHelper<T> : ObservableObject {
    @Published var show = false
    private var result : T?
    private var c : CheckedContinuation<Void, Never>? = nil
    
    func open() async -> T? {
        await withCheckedContinuation { c in
            self.c = c
            Task { await MainActor.run {
                self.show = true
            }}
        }
        return self.result
    }
    
    func close(result: T?) {
        if let c {
            self.result = result
            c.resume()
            self.c = nil
        }
        DispatchQueue.main.async {
            self.show = false
        }

    }
}
typealias YesNoHelper = AlertHelper<Bool>

class InputHelper : AlertHelper<String> {
    @Published var initVal = ""
    
    func open(initVal: String) async -> String? {
        self.initVal = initVal
        return await super.open()
    }
    
    override func open() async -> String? {
        self.initVal = ""
        return await super.open()
    }
}

extension String: @retroactive Error {}
extension String: @retroactive LocalizedError {
    public var errorDescription: String? { return self }
        
//    private static var enBundle : Bundle? = {
//        let language = "en"
//        let path = Bundle.main.path(forResource:language, ofType: "lproj")
//        let bundle = Bundle(path: path!)
//        return bundle
//    }()
    
    var loc: String {
//        let message = NSLocalizedString(self, comment: "")
//        if message != self {
//            return message
//        }
//
//        if let forcedString = String.enBundle?.localizedString(forKey: self, value: nil, table: nil){
//            return forcedString
//        }else {
            return self
//        }
    }
    
    func localizeWithFormat(_ arguments: CVarArg...) -> String{
        String.localizedStringWithFormat(self.loc, arguments)
    }
    
}

class SharedModel: ObservableObject {
    @Published var isLogin = false
    @Published var anisetteServerURL: String {
        didSet { UserDefaults.standard.set(anisetteServerURL, forKey: "AnisetteServer") }
    }
    @Published var authenticationClientInfo: String {
        didSet { UserDefaults.standard.set(authenticationClientInfo, forKey: "AuthenticationClientInfo") }
    }
    @Published var authenticationUserAgent: String {
        didSet { UserDefaults.standard.set(authenticationUserAgent, forKey: "AuthenticationUserAgent") }
    }
    var session: AppleAPISession?
    var account: Account?
    var team: Team?
    
    init() {
        let ud = UserDefaults.standard
        let defaultServer = "https://new.ani.sidestore.io"

        // Migrate values saved by earlier builds. win.ani.sidestore.io is now 502 and
        // the Windows/iTunes identity is rejected by GSA with -22421.
        var server = ud.string(forKey: "AnisetteServer") ?? defaultServer
        let isLegacyServer = server.contains("win.ani.sidestore.io") ||
            server.contains("ani.jkcoxson.com") ||
            (server.contains("ani.sidestore") && !server.contains("new.ani.sidestore.io"))
        if isLegacyServer {
            server = defaultServer
        }

        var clientInfo = ud.string(forKey: "AuthenticationClientInfo") ?? AuthenticationConfiguration.defaultClientInfo
        if clientInfo.contains("Windows;") ||
            clientInfo.contains("com.apple.iTunes") ||
            clientInfo.contains("macOS;") {
            clientInfo = AuthenticationConfiguration.defaultClientInfo
        }

        var userAgent = ud.string(forKey: "AuthenticationUserAgent") ?? AuthenticationConfiguration.defaultUserAgent
        if userAgent.contains("CFNetwork/808.1.4") ||
            userAgent.contains("com.apple.dt.Xcode") {
            userAgent = AuthenticationConfiguration.defaultUserAgent
        }

        anisetteServerURL = server
        authenticationClientInfo = clientInfo
        authenticationUserAgent = userAgent
        AnisetteDataHelper.shared.url = URL(string: anisetteServerURL)
    }

    func authenticationConfiguration() throws -> AuthenticationConfiguration {
        try AuthenticationConfiguration(server: anisetteServerURL,
                                        clientInfo: authenticationClientInfo,
                                        userAgent: authenticationUserAgent)
    }
}

class DataManager {
    static let shared = DataManager()
    let model = SharedModel()
}

extension Error {
    var detailedDescription: String {
        let localizedError = self as? LocalizedError
        var lines: [String] = []
        
        if let description = localizedError?.errorDescription, !description.isEmpty {
            lines.append(description)
        } else {
            let nsError = self as NSError
            lines.append(nsError.localizedDescription)
        }
        
        if let failureReason = localizedError?.failureReason, !failureReason.isEmpty {
            lines.append("Reason: \(failureReason)")
        }
        
        if let recoverySuggestion = localizedError?.recoverySuggestion, !recoverySuggestion.isEmpty {
            lines.append("Suggestion: \(recoverySuggestion)")
        }
        
        let nsError = self as NSError
        if nsError.domain != NSCocoaErrorDomain || nsError.code != 0 {
            lines.append("Domain: \(nsError.domain)")
            lines.append("Code: \(nsError.code)")
        }
        
        if let underlying = nsError.userInfo[NSUnderlyingErrorKey] as? Error {
            lines.append("Underlying: \(underlying.detailedDescription)")
        }
        
        return lines.joined(separator: "\n")
    }
}
