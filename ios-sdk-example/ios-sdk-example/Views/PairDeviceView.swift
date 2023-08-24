
import SwiftUI
public struct PairDeviceView: View {
    @Binding var muses:[String]
    var onSelectDevice : (String) -> Void
    @Environment(\.dismiss) var dismiss
    public init(muses: Binding<[String]>, onSelectDevice: @escaping (String) -> Void) {
        self._muses = muses
        self.onSelectDevice = onSelectDevice
    }
    public var body: some View {
        NavigationView{
            VStack{
                if ($muses.isEmpty){
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle()).scaleEffect(3).padding(.bottom)
                    Text("Please make sure your device is on").font(.largeTitle).padding(.top)
                    Spacer()
                }
                else{
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle()).padding([.bottom, .top])
                    List{
                        ForEach($muses, id: \.self) { muse in
                            Button(muse.wrappedValue){
                                onSelectDevice(muse.wrappedValue)
                                dismiss()
                            }
                        }
                    }
                }
            }.padding([.leading, .bottom, .trailing])
                
        }
    }
}
