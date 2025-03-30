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
    let prefabMarkers = ["I\'m a marker" , "Check me out" , "Click me too!"]
    let focusKey = "focus"
    let enjoymentKey = "enjoyment"
    
    func markerButton(_ label:String) -> some View{
        Button {
            viewModel.setUserMarker(label, timeStamp: Date.now.unixTimeMS())
            } label: {
                Text(label)
                    .padding(.horizontal, 8)
                    .frame(width: 120 , height: 50)
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
                   SessionUploadView()
                       .frame(minWidth: 300, maxWidth: .infinity , minHeight: 400, maxHeight: .infinity)
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
                    ForEach(prefabMarkers, id: \.self){ marker in
                        markerButton(marker)
                    }
                }
                Divider()
                Spacer()
                
                ScrollView{
                    VStack(alignment: .leading, spacing: 5){
                        ForEach(viewModel.realtimePredictionValues.keys, id:\.self){key in
                            if let item = viewModel.realtimePredictionValues[key]{
                                Text("\(key) : \(item)")
                                Divider()
                            }
                        }
                        //passed : Bool , type : QAFailureType
                        Text("QA Passed: \(viewModel.realtimeQaValue.0)")
                        Divider()
                        Text("QA Failure Type: \(viewModel.realtimeQaValue.1)")
                        Divider()
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(minHeight: 200, maxHeight: 400)
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
            viewModel.myViewState = .summery
        case .failure(let error):
            print(error)
            viewModel.lastError = LocalizedAlertError(error , title: "Uploading Session Failed")
            viewModel.myViewState = .summery
        }
        progressShowing = false
    }
}
