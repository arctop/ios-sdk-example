
import SwiftUI
public struct PairDeviceView: View {
    @Binding var devices:[String]
    var onSelectDevice : (String) -> Void
    public init(devices: Binding<[String]>, onSelectDevice: @escaping (String) -> Void) {
        self._devices = devices
        self.onSelectDevice = onSelectDevice
    }
    public var body: some View {
        NavigationView{
            VStack{
                if ($devices.isEmpty){
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle()).scaleEffect(3).padding(.bottom)
                    Text("Please make sure your device is on").font(.largeTitle).padding(.top)
                    Spacer()
                }
                else{
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle()).padding([.bottom, .top])
                    Spacer()
                    ForEach($devices, id: \.self) { device in
                        Button(device.wrappedValue){
                            onSelectDevice(device.wrappedValue)
                        }.buttonStyle(SquareButtonStyle(color: Color.accentColor , size: 12, font: .body))
                    }
                    Spacer()
                }
            }.padding([.leading, .bottom, .trailing])
                
        }
    }
}
