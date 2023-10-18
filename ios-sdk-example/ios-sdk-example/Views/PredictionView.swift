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
    @State var showRetryUpload = false
    @State var showingAddMarker = false
    @State var inputText = ""
    @State var addMarkerTimeStamp:Int64 = 0
    let stanfordMarkers = ["Leave to scrub" , "Return from scrub" , "Eyes open" ,"First Cut" ,"Scope sync" ,"Long conversation" , "GoPro sync" ,
             "Checkpoint A" , "Stitching" , "Attending off, resident on"]
    let focusKey = "focus"
    let enjoymentKey = "enjoyment"
    
    func markerButton(_ label:String) -> some View{
        Button {
            viewModel.setUserMarker(label, timeStamp: Date.now.unixTimeMS())
            } label: {
                Text(label)
                    .padding(.horizontal, 8)
                    .frame(width: 120 , height: 100)
                    .foregroundColor(.white)
                    .background(.cyan)
                    .cornerRadius(12)
            }
    }
    
    var body: some View {
        VStack{
            if (progressShowing){
               VStack{
                     Spacer()
                     SessionUploadView(currentStatus: $viewModel.currentUploadStatus, uploadProgress: $viewModel.uploadProgress,
                                       showRetryUpload: $showRetryUpload, retryUpload: retryUpload, skipRetry: skipRetry)
                     Spacer()
                 }.animation(.default, value: progressShowing)
                 
                 
            }
            else{
                Text("\(viewModel.currentTime)").font(.title2)
                Divider()
                if (showingAddMarker){
                    TextField("Enter custom tag", text: $inputText).padding(.bottom)
                    HStack{
                        Button("Cancel",role: .cancel){
                            withAnimation{
                                inputText = ""
                                showingAddMarker.toggle()
                            }
                        }.buttonStyle(SquareButtonStyle(color: .gray, size: 2 , font: .body))
                        Divider()
                        Button("Submit"){
                            viewModel.setUserMarker(inputText, timeStamp: addMarkerTimeStamp)
                            inputText = ""
                            withAnimation{
                                showingAddMarker.toggle()
                            }
                        }.buttonStyle(SquareButtonStyle(color: .accentColor, size: 2 , font: .body))
                    }.frame(height: 30)
                }
                else{
                    
                    Button("Enter custom tag"){
                        addMarkerTimeStamp = Date().unixTimeMS()
                        withAnimation{
                            showingAddMarker.toggle()
                        }
                    }.buttonStyle(SquareButtonStyle(color:.gray , size: 4 , font: .body))
                    Spacer().frame(height: 55)
                }
                // insert grid with buttons
                HStack{
                    ForEach(0..<3){ i in
                        markerButton(stanfordMarkers[i])
                    }
                }
                HStack{
                    ForEach(3..<6){ i in
                        markerButton(stanfordMarkers[i])
                    }
                }
                HStack{
                    ForEach(6..<9){ i in
                        markerButton(stanfordMarkers[i])
                    }
                }
                HStack{
                    Spacer().frame(width: 120, height: 100, alignment: .center)
                    
                    markerButton(stanfordMarkers[9])
                    Spacer().frame(width: 120, height: 100, alignment: .center)
                    
                }
                HStack{
                    Text("Focus | \(Int(viewModel.realtimePredictionValues["focus"] ?? -1))").frame(width: 120, height: 100, alignment: .center)
                    Text("Heartrate | \(Int(viewModel.realtimePredictionValues["heart_rate"] ?? -1))").frame(width: 120, height: 100, alignment: .center)
                    Text("Enjoyment | \(Int(viewModel.realtimePredictionValues["enjoyment"] ?? -1))").frame(width: 120, height: 100, alignment: .center)
                }
                Spacer()
                Button("Stop Recording"){
                    Task{
                        await tryUploadSession()
                    }
                }.buttonStyle(SquareButtonStyle())
            }
        }
    }
    private func tryUploadSession() async{
        progressShowing = true
        let result = await viewModel.sdk.finishSession()
        switch result {
        case .success(_):
            progressShowing = false
            viewModel.myViewState = .summery
        case .failure(let error):
            print(error)
            viewModel.lastError = LocalizedAlertError(error , title: "Uploading Session Failed")
            //showRetryUpload = true
        }
    }
    private func skipRetry(){
        progressShowing = false
        showRetryUpload = false
//        viewModel.userDismissedUploadFailed()
    }
    private func retryUpload(){
        Task{
            await tryUploadSession()
        }
    }
}
