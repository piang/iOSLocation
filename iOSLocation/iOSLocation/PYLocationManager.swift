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
    
    /**
     * 后台上传位置需求：
     * a.如果用户的位置在持续变化 则隔一段时间上报一次
     * b.如果用户的移动速度很慢 则隔一段距离上报一次
     * c.如果用户的位置在到达某处后没有变化 则不继续上报
     * d.切换到后台也要能定位上报
     * e.APP因各种原因终止运行后(用户主动关闭, 系统杀掉) 也要能定位上报
    **/
    var minSpeed:Double = 3      //最小速度
    var minFilter:Double = 50    //最小范围
    var minInteval:Double = 10   //最小间隔
    
    static let shareLocationManger = PYLocationManager()
    
    override init() {
        locationManager = CLLocationManager()
        geocoder = CLGeocoder()
        super.init()
        locationManager.delegate = self
        
        //设置位置的准确度
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        //设置移动距离多少才采集数据
        locationManager.distanceFilter = minFilter
        
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
        
        if (locations[0].speed < minSpeed) {
            
            if (fabs(self.locationManager.distanceFilter - self.minFilter) / self.minFilter > 0.1) { //控制变化大于10%
                self.locationManager.distanceFilter = self.minFilter //需求b,c
            }
        }
        else {
            let lastSpeed:Double = self.locationManager.distanceFilter / self.minInteval
            
            if (fabs(lastSpeed-locations[0].speed)/lastSpeed > 0.1) //控制变化大于10%
            {
                self.locationManager.distanceFilter = locations[0].speed * self.minInteval; //需求a
            }
        }
        
        //上传坐标
        print("上传：" + String(locations[0]))
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