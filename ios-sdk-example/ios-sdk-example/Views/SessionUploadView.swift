//
//  SessionUploadView.swift
//  ArctopCentral
//
//  Created by Shai on 28/03/2023.
//

import SwiftUI
import ArctopSDK
struct SessionUploadView: View {
    @ObservedObject var viewModel: CombineViewModel
    @State var uploadProgress :Float = 0.0
    var body: some View {
        VStack{
            ProgressView(){
                Text("Uploading... \(Int(uploadProgress))%")
            }.progressViewStyle(.circular)
            .onReceive(viewModel.$uploadProgress){
                newValue in self.uploadProgress = newValue
            }
        }
    }
}
