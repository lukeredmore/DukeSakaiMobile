//
//  Utils.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/18/22.
//

import UIKit
import WebKit

public func print(_ items: String..., filename: String = #file, function : String = #function, line: Int = #line, separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    let pretty = " ⭐️ [\(URL(fileURLWithPath: filename).lastPathComponent.replacingOccurrences(of: ".swift", with: ""))] "
        let output = items.map { "\($0)" }.joined(separator: separator)
        Swift.print(pretty+output, terminator: terminator)
    #else
        Swift.print(items)
    #endif
}

public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        let output = items.map { "\($0)" }.joined(separator: separator)
    Swift.print(" ⭐️ [\(URL(fileURLWithPath: #file).lastPathComponent.replacingOccurrences(of: ".swift", with: ""))] \(output)", terminator: terminator)
    #else
        Swift.print(items)
    #endif
}

extension Dictionary where Key == String {
    func get<T: Any>(_ key: String, as: T.Type = T.self) throws -> T {
        guard let val_any = self[key] else {
            throw SakaiDataRetrievalError.failedToFindKeyInJson(key: key)
        }
        guard let val = val_any as? T else {
            throw SakaiDataRetrievalError.failedToParseKeyInJsonAsType(key: key)
        }
        return val
    }
    
    func get<T: Any>(_ key: [String], as: T.Type = T.self) throws -> T {
        if key.isEmpty {
            throw SakaiDataRetrievalError.failedToFindKeyInJson(key: "")
        } else if key.count == 1 {
            return try get(key[0])
        } else {
            var current : [String : AnyObject] = try get(key[0])
            for i in 1..<key.count - 1 {
                print(current)
                print(key[i])
                current = try current.get(key[i])
                print(current)
            }
            return try current.get(key[key.count - 1])
        }
        

    }
    
    func percentEncoded() -> Data? {
        map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed: CharacterSet = .urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
extension Data {
    init?(base64Encoded: String, autoPadding: Bool) {
        if !autoPadding {
            self.init(base64Encoded: base64Encoded)
        } else {
            var encoded = base64Encoded
            let remainder = encoded.count % 4
            if remainder > 0 {
                encoded = encoded.padding(
                    toLength: encoded.count + 4 - remainder,
                    withPad: "=", startingAt: 0)
            }
            self.init(base64Encoded: encoded)
        }
    }
}

extension UIColor {
    var hex : String {
        let components = self.cgColor.components
        if components?.count == 2 {
            let gs: CGFloat = components?[0] ?? 0.0
            
            let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(gs * 255)), lroundf(Float(gs * 255)), lroundf(Float(gs * 255)))
            return hexString
        } else {
            let r: CGFloat = components?[0] ?? 0.0
            let g: CGFloat = components?[1] ?? 0.0
            let b: CGFloat = components?[2] ?? 0.0

            let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
            return hexString
        }
    }
}

extension String {
    private func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int? = nil, to: Int? = nil) -> String {
        let fromIndex = from != nil ? index(from: from!) : startIndex
        let toIndex = to != nil ? index(from: to!) : endIndex
        return String(self[fromIndex..<toIndex])
    }
}

extension WKWebView {
    func populateFileInput(querySelector: String, data: Data, filename: String, type: String) {
        let byteArray = [UInt8](data)
        
        self.evaluateJavaScript("""
            const byteArrayString = "\(byteArray)"
            const intArray = byteArrayString.substring(1, byteArrayString.length - 1).split(", ").map(x => Number(x));
            const byteArray = new Uint8Array(intArray);
            const blob = new Blob([byteArray], { type: "\(type)" });
            const file = new File([blob], "\(filename)");
            
            let container = new DataTransfer();
            container.items.add(file);
            $("\(querySelector)")[0].files = container.files;
            $("\(querySelector)")[0].onchange();
            byteArray[0]
        """)
    }
}

public extension FileManager {
    func copyOrReplace(sourceUrl: URL, destinationUrl: URL) throws {
        if fileExists(atPath: destinationUrl.path) {
            try removeItem(at: destinationUrl)
        }
        try copyItem(at: sourceUrl, to: destinationUrl)
    }
}

extension UserDefaults {
    static var shared = UserDefaults(suiteName: "group.DukeSakai")!
}
