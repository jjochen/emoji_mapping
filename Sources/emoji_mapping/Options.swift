//
//  Options.swift
//  emoji_mapping
//
//  Created by Jochen on 11.04.18.
//

import Foundation

internal enum OutputType: String, CustomStringConvertible {
    case enumDefinitions = "enum"
    case keyDefinitions = "keys"
    case switchCases = "switch"

    var description: String {
        return rawValue
    }
}

internal struct OptionKey {
    let short: String
    let long: String
    let descriptionText: String

    static let help = OptionKey(short: "h",
                                long: "help",
                                descriptionText: "Print this help")
    static let mapping = OptionKey(short: "m",
                                   long: "mapping",
                                   descriptionText: "Path to mapping file")
    static let emojis = OptionKey(short: "e",
                                  long: "emojis",
                                  descriptionText: "Path to emoji file")
    static let type = OptionKey(short: "t",
                                long: "type",
                                descriptionText: "Output type [enum, kays switch]")
    static let verbose = OptionKey(short: "v",
                                   long: "verbose",
                                   descriptionText: "Print more information about the execution")

    var helpText: String {
        return "-\(short), -\(long): \(descriptionText)."
    }
}

internal class OptionParser {
    var help: Bool {
        return arguments.contains("help") || argumentsContain(option: .help)
    }

    var isVerbose: Bool {
        return bool(forOption: .verbose)
    }

    var emojisURL: URL? {
        let url = fileURL(forPath: options.string(forOption: .emojis),
                          relativeTo: FileManager.default.currentDirectoryPath)
        return url
    }

    var mappingURL: URL? {
        let url = fileURL(forPath: options.string(forOption: .mapping),
                          relativeTo: FileManager.default.currentDirectoryPath)
        return url
    }

    var type: OutputType? {
        guard let typeString = string(forOption: .type) else {
            return nil
        }
        return OutputType(rawValue: typeString)
    }
}

fileprivate extension OptionParser {
    var options: UserDefaults {
        return UserDefaults.standard
    }

    var arguments: [String] {
        return CommandLine.arguments
    }

    func argumentsContain(option: OptionKey) -> Bool {
        return arguments.contains("-\(option.long)") || arguments.contains("-\(option.short)")
    }

    func string(forOption option: OptionKey) -> String? {
        return options.string(forOption: option)
    }

    func bool(forOption option: OptionKey) -> Bool {
        return options.bool(forOption: option)
    }

    func fileURL(forPath path: String?, relativeTo basePath: String?) -> URL? {
        guard var path = path else {
            return nil
        }
        path = NSString(string: path).standardizingPath

        if path.starts(with: "/") {
            return URL(fileURLWithPath: path)
        }

        guard let basePath = basePath else {
            return nil
        }

        let baseURL = URL(fileURLWithPath: basePath)
        return URL(fileURLWithPath: path, relativeTo: baseURL)
    }
}

extension UserDefaults {
    func string(forOption option: OptionKey) -> String? {
        guard let string = object(forOption: option) as? String else {
            return nil
        }
        return string
    }

    func object(forOption option: OptionKey) -> Any? {
        return object(forKey: option.long) ?? object(forKey: option.short)
    }

    func url(forOption option: OptionKey) -> URL? {
        return url(forKey: option.long) ?? url(forKey: option.short)
    }

    func bool(forOption option: OptionKey) -> Bool {
        return bool(forKey: option.long) || bool(forKey: option.short)
    }
}
