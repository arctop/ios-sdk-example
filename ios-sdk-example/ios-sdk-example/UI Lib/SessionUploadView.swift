//
//  SessionUploadView.swift
//  NeuosCentral
//
//  Created by Shai on 28/03/2023.
//

import SwiftUI
import NeuosSDK
struct SessionUploadView: View {
    @Binding var currentStatus: UploadStatus
    @Binding var uploadProgress:Float
    @Binding var showRetryUpload:Bool
    var failedImageName : String = "xmark.icloud"
    var retryUpload: () -> Void
    var skipRetry: () -> Void
    var body: some View {
        VStack{
            switch currentStatus{
                case .starting , .archiving:
                      // sort of hacky, but it can be that the upload status is ok,
                      // however there was another error from graphQL that happened.
                      // so this IF/Else covers it
                    if (!showRetryUpload){
                        ProgressView(){
                            Text("Prepering session for upload...")
                        }.progressViewStyle(.circular)
                    }
                    else{
                        Image(systemName: failedImageName)
                    }
                case .failed:
                    Image(systemName: failedImageName)
                default:
                    ProgressView("Uploading ...", value: uploadProgress, total: 100).progressViewStyle(.linear)
            }
            
            if showRetryUpload{
                Button("Retry Upload"){
                    showRetryUpload = false
                    retryUpload()
                }.padding()
                Button("Exit anyways"){
                    skipRetry()
                }.padding(.horizontal)
            }
        }
    }
}

struct SessionUploadView_Previews: PreviewProvider {
    static var previews: some View {
        SessionUploadView(currentStatus: .constant(.starting) , uploadProgress: .constant(0) , showRetryUpload: .constant(false)
                          , retryUpload: {} , skipRetry: {})
    }
}
