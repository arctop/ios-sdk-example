//
//  SecureInputView.swift
//  UITests
//
//  Created by Shai on 22/01/2023.
//

import SwiftUI

struct SecureInputView: View {
        @FocusState var focused: focusedField?
        @State var showPassword: Bool = false
        @Binding var password: String
        var placeHolder:String
        var body: some View {
            HStack {
                ZStack(alignment: .trailing) {
                    TextField(placeHolder, text: $password)
                        .focused($focused, equals: .unSecure)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                    // This is needed to remove suggestion bar, otherwise swapping between
                    // fields will change keyboard height and be distracting to user.
                        .keyboardType(.alphabet)
                        .opacity(showPassword ? 1 : 0)
                    SecureField(placeHolder, text: $password)
                        .focused($focused, equals: .secure)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        //.textContentType(.oneTimeCode)
                        .opacity(showPassword ? 0 : 1)
                    Button(action: {
                        showPassword.toggle()
                        focused = focused == .secure ? .unSecure : .secure
                    }, label: {
                        Image(systemName: self.showPassword ? "eye.slash.fill" : "eye.fill")
                    })
                }
            }
        }
        // Using the enum makes the code clear as to what field is focused.
        enum focusedField {
            case secure, unSecure
        }
}

struct SecureInputView_Previews: PreviewProvider {
    static var previews: some View {
        SecureInputView(password: .constant("testPassword"), placeHolder: "pass")
    }
}
