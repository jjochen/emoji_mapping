//
//  Emoji.swift
//  emoji_mapping
//
//  Created by Jochen on 10.04.18.
//

import Foundation

class Emoji: Decodable, Encodable {
    var annotation: String
//    var group: Int
    var hexcode: String
//    var order: Int
    var shortcodes: [String]
//    var tags: [String]?
    var unicode: String
//    var skins: [Emoji]?

    var shortname: String {
        if let userDefaultsValue = UserDefaults.standard.string(forKey: userDefaultShortNameKey) {
            return userDefaultsValue
        }

        let newValue = chooseShortCode()
        UserDefaults.standard.set(newValue, forKey: userDefaultShortNameKey)
        return newValue
    }

    var hexcodeValueString: String {
        let components = hexcode.components(separatedBy: CharacterSet(charactersIn: "-"))
        var components0x: [String] = []
        components.forEach { component in
            components0x.append("0x\(component)")
        }
        return components0x.joined(separator: ", ")
    }

    var keyName: String {
        let components = shortname.components(separatedBy: CharacterSet(charactersIn: "_"))
        var keySuffix = ""
        components.forEach { component in
            keySuffix.append(component.capitalized)
        }
        return "Key_Emoji\(keySuffix)"
    }

    var enumNameSuffix: String {
        return shortname.uppercased()
    }

    var enumName: String {
        return "EMOJI_\(enumNameSuffix)"
    }

    var enumDefinition: String {
        return "  \(enumName),"
    }

    var keyDefinition: String {
        return "#define \(keyName) EMOJI_KEY(\(enumNameSuffix)) // \(unicode) (\(hexcodeValueString)) \(annotation)"
    }

    var switchCase: String {
        var components: [String] = []
        for char in unicode.utf16 {
            let hexString = String(char, radix: 16)
            components.append("0x\(hexString)")
        }
        let size = components.count
        let sequence = components.joined(separator: ", ")

        return "  case \(enumName):\n    size = \(size);\n    sequence = new uint32_t[size]{\(sequence)};\n    break;"
    }

    var readmeDot: String {
        return "  * \(unicode) \(keyName)"
    }

    func chooseShortCode() -> String {
        if shortcodes.count == 0 {
            return annotation
        }

        if shortcodes.count == 1 {
            return shortcodes.first!
        }

        var humanReadableIndex = Int(0)
        while humanReadableIndex < 1 || humanReadableIndex > shortcodes.count {
            print("Which do you prefere for \(unicode)  ?")
            shortcodes.enumerated().forEach { offset, code in
                print("  \(offset + 1): \(code)")
            }
            humanReadableIndex = Int(readLine() ?? "") ?? 0
        }
        return shortcodes[humanReadableIndex - 1]
    }

    var userDefaultShortNameKey: String {
        return "shortname_\(hexcode)"
    }
}

extension Emoji: Equatable {
    static func == (lhs: Emoji, _: Emoji) -> Bool {
        return lhs.unicode == lhs.unicode
    }
}
