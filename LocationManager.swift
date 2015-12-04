//
//  LocationManager.swift
//  LocationManager
//
//  Created by impressly on 12/3/15.
//  Copyright © 2015 OTT. All rights reserved.
//

import Foundation
import Foundation
import CoreLocation

enum LocationManagerMode {
    case latLon
    case cityDistrict
}

protocol LocationManagerDelegate: NSObjectProtocol {
    func didUpdateLatLon(locationManager: LocationManager, lat: Float, lon: Float)
    func didSetCityDistrict(locationManager: LocationManager, city: String, district: String)
}

class LocationManager: NSObject {
    
    // Core Location
    let manager = CLLocationManager()
    var currentLocation: CLLocation?
    
    //LocationManagerDelegate
    weak var delegate: LocationManagerDelegate?
    
    // user settings
    var mode: LocationManagerMode
    
    // city/district mode
    var city: String
    var district: String
    
    // MARK: Lifecycle
    override init() {
        self.currentLocation = CLLocation()
        self.mode = LocationManagerMode.latLon
        city = "上海"
        district = "徐汇区"
        
        super.init()
    }
    
    deinit {
        manager.stopUpdatingLocation()
    }
    
    // MARK: Setup
    func setup() {
        // TODO: user default read -- Mode, lat/lon or city/district
    }
    
    //MARK:IOS8 以后才能使用定位功能
    private func ios8() -> Bool {
        
        return UIDevice.currentDevice().systemVersion >= "8.0"
    }
    
    // get user permission
    func allowRequest() {
        if (ios8()) {
            
            //始终允许访问位置信息
            self.manager.requestAlwaysAuthorization()
            
            //使用应用程序期间允许访问位置数据
            self.manager.requestWhenInUseAuthorization()
        }
    }
    
    func getLatLon() {
        self.allowRequest()
        if (CLLocationManager.locationServicesEnabled()) {
            self.manager.desiredAccuracy = kCLLocationAccuracyBest
            
            self.manager.distanceFilter = kCLLocationAccuracyHundredMeters
            
            self.manager.delegate = self
            self.manager.startUpdatingLocation()
        }
    }
    
    // TODO: Save/Load settings to user default
    
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //取得locations数组的最后一个
        let location: CLLocation = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            let lat = Float(location.coordinate.latitude)
            let lon = Float(location.coordinate.longitude)
            
            self.currentLocation = location
            print("[LocationManager didUpdateLocations] lat = \(lat),  lon = \(lon)")
            
            //传值给代理
            self.delegate?.didUpdateLatLon(self, lat: lat, lon: lon)
            self.manager.stopUpdatingLocation()
        }
    }
    
    //MARK:定位错误信息
    func locationManager(manager: CLLocationManager, didFinishDeferredUpdatesWithError error: NSError?) {
        
        print("\(error)\(error?.description)")
    }
    
}