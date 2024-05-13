//
//  LoginView.swift
//  ios-sdk-example
//
//  Created by Shai Kalev on 24/08/2023.
//

import SwiftUI

struct LoginView: View {
    @State var email:String = ""
    @State var password:String = ""
    @ObservedObject var viewModel: ViewModel
    var body: some View {
        
        LoadingView(isShowing: $viewModel.loadingShowing, loadingMessage: $viewModel.loadingMessage){
            VStack{
                //TopBarLogo().padding(.bottom , 100.0)
                Text("Login")
                    .bold()
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom)
                    .onAppear(){
                        Task{
                            await viewModel.login()
                        }
                    }
                
//                TextField("Email", text: $email)
//                    .autocorrectionDisabled(true)
//                    .textInputAutocapitalization(.never)
//                    .keyboardType(.emailAddress)
//                
//                    .padding(.bottom)
//                SecureInputView(password: $password, placeHolder: "Password")
//                    .padding(.bottom)
//                
//                
//                Button("Login"){
//                    onRegSuccess(email, password)
//                }
//                .disabled(isLoginButtonDisabled())
//                .buttonStyle(SquareButtonStyle(size: 4))
//                .padding(.bottom)
                
            }.padding()
        }
    }
//    private func onRegSuccess(_ email:String, _ password:String){
//        Task{
//            let result = await viewModel.login(email: email, password: password)
//            switch result{
//                case .failure(let error):
//                viewModel.lastError = LocalizedAlertError(error , title: "Login Failed!")
//                print("Error")
//            case .success(_):
//                // all good
//                break
//            }
//        }
//    }
//    private func isLoginButtonDisabled() -> Bool{
//        return password.isEmpty || email.isEmpty
//    }
}

