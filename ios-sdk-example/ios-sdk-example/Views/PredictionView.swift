//
//  PredictionView.swift
//  ios-sdk-example
//
//  Created by Shai Kalev on 08/08/2023.
//

import SwiftUI

struct PredictionView: View {
    @State var progressShowing:Bool = false
    @ObservedObject var viewModel:ViewModel
    var body: some View {
        VStack{
            if (progressShowing){
                ProgressView()
            }
            else{
                List{
                    Text("QA passed:\(viewModel.realtimeQaValue.0.description) , reason: \(viewModel.realtimeQaValue.1.description)")
                    
                    ForEach(viewModel.realtimePredictionValues.keys , id: \.self){ key in
                        Text("\(key) : \(viewModel.realtimePredictionValues[key]!.description)")
                    }
                    ForEach(viewModel.realtimeMotionData.keys , id: \.self){ key in
                        Text("\(key) : \(viewModel.realtimeMotionData[key]!.description)")
                    }
                }.padding(.bottom)
                Button("Finish"){
                    Task{
                        await tryUploadSession()
                    }
                }
            }
        }
    }
    private func tryUploadSession() async{
        progressShowing = true
        let result = await viewModel.sdk.finishSession()
        switch result {
        case .success(_):
            progressShowing = false
            viewModel.myViewState = .start
        case .failure(let error):
            print(error)
            viewModel.lastError = LocalizedAlertError(error , title: "Uploading Session Failed")
            //showRetryUpload = true
        }
    }
}
