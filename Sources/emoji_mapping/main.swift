import AppKit
import Foundation

let executableName = NSString(string: CommandLine.arguments.first!).pathComponents.last!
let options = OptionParser()

func usage() {
    print("\(executableName) options")
    print("")
    print("  \(OptionKey.help.helpText)")
    print("  \(OptionKey.mapping.helpText)")
    print("  \(OptionKey.emojis.helpText)")
    print("  \(OptionKey.type.helpText)")
    print("  \(OptionKey.verbose.helpText)")
    print("")
    print("You can download the mapping file here:")
    print("https://raw.githubusercontent.com/milesj/emojibase/master/packages/data/en/compact.json")
}

if options.help {
    usage()
    exit(0)
}

do {
    guard let mappingURL = options.mappingURL else {
        throw CommandLineError.tooFewArguments(descriptionOfRequiredArguments: "path to mapping json")
    }
    guard let emojisURL = options.emojisURL else {
        throw CommandLineError.tooFewArguments(descriptionOfRequiredArguments: "path to emoji file")
    }
    guard let type = options.type else {
        throw CommandLineError.tooFewArguments(descriptionOfRequiredArguments: "output type")
    }

    let data = try Data(contentsOf: mappingURL, options: .alwaysMapped)
    let emojiMapping = try JSONDecoder().decode(FailableCodableArray<Emoji>.self, from: data).elements

    let separators = CharacterSet(charactersIn: "\n\t\\|,;: ")
    let emojis = try String(contentsOf: emojisURL, encoding: .utf8).components(separatedBy: separators)

    var mappedEmojies = [Emoji]()
    emojiMapping.forEach { emoji in
        if emojis.contains(emoji.unicode) {
            print("\(emoji.shortname) \(emoji.unicode)")
            mappedEmojies.append(emoji)
        }
    }
    print("")

    var results: [String] = []
    mappedEmojies.forEach { emoji in
        switch type {
        case .enumDefinitions:
            results.append(emoji.enumDefinition)
        case .keyDefinitions:
            results.append(emoji.keyDefinition)
        case .switchCases:
            results.append(emoji.switchCase)
        }
    }

    let resultString = results.joined(separator: "\n")
    print(resultString)
    print("")
    print("Copied to pastboard!")

    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(resultString, forType: .string)

    exit(0)

} catch let error {
    error.handle()
}
