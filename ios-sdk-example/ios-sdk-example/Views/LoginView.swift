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
            }.padding()
        }
    }
}

