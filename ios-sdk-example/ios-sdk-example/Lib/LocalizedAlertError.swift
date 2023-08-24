//
//  LocalizedError.swift
//  NeuosCentral
//
//  Created by Shai on 30/01/2023.
//

import Foundation
public struct StringError :Error {
    init(_ stringError:String) {
        localizedDescription = stringError
    }
    public private(set) var localizedDescription: String
}
public struct LocalizedAlertError: LocalizedError {
    private let underlyingError: Error
    let title:String
    public var errorDescription: String? {
        title
    }
    public var recoverySuggestion: String? {
        guard let localizedError = underlyingError as? LocalizedError else { return underlyingError.localizedDescription }
        return localizedError.recoverySuggestion
    }

    init(_ error: Error, title:String = "Error") {
        self.title = title
        underlyingError = error
    }
}
