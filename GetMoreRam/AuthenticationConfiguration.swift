import Foundation

struct AuthenticationConfiguration {
    static let defaultClientInfo = "<MacBookPro18,3> <macOS;26.6;25F84> <com.apple.AuthKit/1 (com.apple.akd/1.0)>"
    static let defaultUserAgent = "AuthKit/1 (Macintosh; OS X 26.6) (com.apple.akd/1.0)"

    let serverURL: URL
    let clientInfo: String
    let userAgent: String

    init(server: String, clientInfo: String, userAgent: String) throws {
        guard let url = URL(string: server.trimmingCharacters(in: .whitespacesAndNewlines)),
              ["https", "http"].contains(url.scheme?.lowercased() ?? ""),
              let host = url.host, !host.isEmpty,
              url.user == nil, url.password == nil,
              url.query == nil, url.fragment == nil else {
            throw ConfigurationError.invalidServer
        }
        self.serverURL = url
        self.clientInfo = try Self.header(clientInfo, name: "Client Info")
        self.userAgent = try Self.header(userAgent, name: "User Agent")
    }

    private static func header(_ value: String, name: String) throws -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              trimmed.unicodeScalars.allSatisfy({ (32...126).contains($0.value) }) else {
            throw ConfigurationError.invalidHeader(name)
        }
        return trimmed
    }

    enum ConfigurationError: LocalizedError {
        case invalidServer
        case invalidHeader(String)

        var errorDescription: String? {
            switch self {
            case .invalidServer:
                return "Enter an HTTP or HTTPS Anisette server URL without credentials, a query, or a fragment."
            case .invalidHeader(let name):
                return "\(name) must contain a nonempty, single line of printable ASCII text."
            }
        }
    }
}
