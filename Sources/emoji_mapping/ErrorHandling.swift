//
//  ErrorHandling.swift
//  emoji_mapping
//
//  Created by Jochen on 11.04.18.
//

import Foundation

internal enum CommandLineError: Error, CustomStringConvertible {
    case tooManyArguments
    case tooFewArguments(descriptionOfRequiredArguments: String)
    case invalidArgument(reason: String)
    case internalError(reason: String)

    var description: String {
        switch self {
        case .tooManyArguments:
            return "Too many arguments"

        case let .tooFewArguments(descriptionOfRequiredArguments):
            return "Missing argument(s). Must specify \(descriptionOfRequiredArguments)."

        case let .invalidArgument(reason):
            return "Invalid argument. \(reason)."

        case let .internalError(reason):
            return "Internal error. \(reason)."
        }
    }
}

internal extension Error {
    func handle() {
        if let error = self as? CommandLineError {
            print("Error parsing arguments: \(error)")
            print("")
            usage()
            exit(1)
        }

        let error = self as NSError
        let highLevelFailure = error.localizedDescription
        var errorOutput = highLevelFailure

        if let detailedFailure = error.localizedRecoverySuggestion ?? error.localizedFailureReason {
            errorOutput += ": \(detailedFailure)"
        }

        print("Error: \(errorOutput).")
        exit(1)
    }
}
