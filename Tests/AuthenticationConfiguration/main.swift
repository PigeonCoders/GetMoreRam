import Foundation

func expectInvalid(_ server: String = "https://new.ani.sidestore.io", client: String = AuthenticationConfiguration.defaultClientInfo, agent: String = AuthenticationConfiguration.defaultUserAgent) {
    do {
        _ = try AuthenticationConfiguration(server: server, clientInfo: client, userAgent: agent)
        fatalError("Accepted invalid configuration")
    } catch {}
}

let config = try AuthenticationConfiguration(server: " https://new.ani.sidestore.io/ ", clientInfo: AuthenticationConfiguration.defaultClientInfo, userAgent: " AuthKit/1 (Macintosh; OS X 26.6) (com.apple.akd/1.0) ")
precondition(config.serverURL.absoluteString == "https://new.ani.sidestore.io/")
precondition(config.clientInfo == "<MacBookPro18,3> <macOS;26.6;25F84> <com.apple.AuthKit/1 (com.apple.akd/1.0)>")
precondition(config.userAgent == "AuthKit/1 (Macintosh; OS X 26.6) (com.apple.akd/1.0)")
expectInvalid("ftp://example.com")
expectInvalid("https://")
expectInvalid("https://user:password@example.com")
expectInvalid("https://example.com?query=1")
expectInvalid("https://example.com#fragment")
expectInvalid(client: "   ")
expectInvalid(agent: "a\r\nInjected: header")
expectInvalid(client: "a\0b")
expectInvalid(agent: "a\tb")
print("Authentication configuration checks passed")
