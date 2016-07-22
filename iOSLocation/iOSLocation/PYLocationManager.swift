//
//  PYLocationManager.swift
//  iOSLocation
//
//  Created by 洋 裴 on 16/7/20.
//  Copyright © 2016年 玖富集团. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class PYLocationManager: NSObject,CLLocationManagerDelegate {
    
    var locationManager:CLLocationManager
    var geocoder:CLGeocoder
    
    override init() {
        locationManager = CLLocationManager()
        geocoder = CLGeocoder()
        super.init()
        locationManager.delegate = self
        
        //设置位置的准确度
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        //设置移动距离多少才采集数据
        locationManager.distanceFilter = 50
        
        /**
         *>=8.0 版本需调用此方法去请求权限
         */
        if ((Float(UIDevice.currentDevice().systemVersion)) >= 8.0) {
            locationAuthorizationJudge()
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
    }
    
    func locationAuthorizationJudge() -> Void {
        let status:CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        
        //未决定状态
        if (status == CLAuthorizationStatus.NotDetermined) {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        //拒绝状态
        else if(status == CLAuthorizationStatus.Denied){
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        //授权状态
        else if (status == CLAuthorizationStatus.AuthorizedAlways || status == CLAuthorizationStatus.AuthorizedWhenInUse) {
            
        }
    }
    
    func locationGeocode(locationName:String,completionHander:((placemark:CLPlacemark) -> Void)) -> Void {
        
        geocoder.geocodeAddressString(locationName) { (placeMarks:[CLPlacemark]?, error:NSError?) in
            if (error == nil) {
                
                print(placeMarks?.first?.location?.coordinate)
                completionHander(placemark:(placeMarks?.first)!)
            }
            else {
                print(error)
            }
        }
    }
    
    func reverseGeocode(latitude:String,longitude:String,completionHander:((placemark:CLPlacemark) -> Void)) -> Void {
        
        let loc = CLLocation(latitude: NSString(string:latitude).doubleValue ,longitude: NSString(string:longitude).doubleValue)
        
        geocoder.reverseGeocodeLocation(loc) { (placeMarks:[CLPlacemark]?, error:NSError?) in
            
            if (error == nil) {
                completionHander(placemark: (placeMarks?.first)!)
            }
            else {
                print(error)
            }
        }
    }
    
    
}