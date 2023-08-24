//
//  HardwareMonitorModel.swift
//

import Foundation
import CoreBluetooth
import Network
import UIKit
public class HardwareMonitorModel: NSObject, CBCentralManagerDelegate , ObservableObject{
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        DispatchQueue.main.async {
            self.btState = central.state
        }
    }
    
    private var centralManager: CBCentralManager!
    private let netMonitor = NWPathMonitor()
    private let hardwareMonitorQueue = DispatchQueue(label: "HardwareMonitor")
    @Published public private(set) var btState: CBManagerState = .unknown
    @Published public private(set) var networkAvailable: Bool = true
    @Published public private(set) var isIOSDevicePluggedIn: Bool = false
    private let uiDevice:UIDevice
    override init(){
        uiDevice = UIDevice.current
        super.init()
        centralManager = .init(delegate: self, queue: hardwareMonitorQueue)
        netMonitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.networkAvailable = (path.status == .satisfied)
            }
        }
        uiDevice.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(batteryStateDidChange), name: UIDevice.batteryStateDidChangeNotification, object: nil)
        updateBatteryPluggedStatus()
        netMonitor.start(queue: hardwareMonitorQueue)
        
    }
    
    public func getBtErrorText() ->String{
        switch (btState){
        case .poweredOff:
            return "Please turn bluetooth on"
        case .unauthorized:
            return "Please allow Neuos to use bluetooth"
        default:
            return"Error finding bluetooth"
        }
    }
    
    private func updateBatteryPluggedStatus(){
        isIOSDevicePluggedIn = uiDevice.batteryState != .unplugged
    }
    
    @objc func batteryStateDidChange(notification: NSNotification){
        updateBatteryPluggedStatus()
    }
}
