//
//  ViewExtensions.swift
//  UITests
//
//  Created by Shai on 26/01/2023.
//

import Foundation
import SwiftUI
extension View {
 /// Applies the given transform if the given condition evaluates to `true`.
 /// - Parameters:
 ///   - condition: The condition to evaluate.
 ///   - transform: The transform to apply to the source `View`.
 /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    func errorAlert(error: Binding<LocalizedAlertError?>, buttonTitle: String = "OK") -> some View {
        return alert(isPresented: .constant(error.wrappedValue != nil), error: error.wrappedValue) { _ in
                Button(buttonTitle) {
                    error.wrappedValue = nil
                }
            } message: { error in
                Text(error.recoverySuggestion ?? "" )
            }
        }
}
