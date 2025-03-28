import Foundation

public class JWT {
    let sub: String?

    init(token: String) {
        let sub = JWT.decode(token)
        self.sub = sub
    }

    private static func decode(_ token: String) -> String? {
        let segments = token.split(separator: ".")
        
        guard segments.count == 3, let payloadData = decodeBase64URL(String(segments[1])) else {
            return nil
        }

        do {
            if let json = try JSONSerialization.jsonObject(with: payloadData, options: []) as? [String: Any] {
                return json["sub"] as? String
            }
        } catch {
            print("Failed to decode JWT payload: \(error)")
        }
        
        return nil
    }
    
    private static func decodeBase64URL(_ base64URL: String) -> Data? {
        var base64 = base64URL
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        while base64.count % 4 != 0 {
            base64.append("=")
        }
        
        return Data(base64Encoded: base64)
    }
}
