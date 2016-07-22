//
//  ViewController.swift
//  iOSLocation
//
//  Created by 洋 裴 on 16/7/19.
//  Copyright © 2016年 玖富集团. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController,MKMapViewDelegate {

    var locationManager:PYLocationManager?
    var currentLocation:CLLocationCoordinate2D?
    var destinationLocation:CLLocationCoordinate2D?
    
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    
    @IBOutlet weak var locationMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager = PYLocationManager()
        locationMapView.delegate = self
        locationMapView.userLocation.title = "当前位置"
        /**
         * 是否显示比例尺
         **/
        locationMapView.showsScale = true
        
        /**
         * 是否显示指南针
         **/
        locationMapView.showsCompass = true
    }
    
    override func viewWillAppear(animated: Bool) {
        locationMapView.showsUserLocation = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func geocodeButtonClick(sender: AnyObject) {
        
        locationManager?.locationGeocode(addressTextField.text!) { (placemark:CLPlacemark)  in
            let ann = MKPointAnnotation()
            ann.coordinate = (placemark.location?.coordinate)!
            ann.title = placemark.name
            ann.subtitle = placemark.locality
            
            self.locationMapView.addAnnotation(ann)
            self.locationMapView.setRegion(MKCoordinateRegionMakeWithDistance(ann.coordinate, 150.0, 150.0) ,animated:false)
        }
    }

    @IBAction func reverseGeocodeButtonClick(sender: AnyObject) {
        locationManager?.reverseGeocode(latitudeTextField.text!, longitude: longitudeTextField.text!) { (placemark:CLPlacemark) in
            let ann = MKPointAnnotation()
            ann.coordinate = (placemark.location?.coordinate)!
            ann.title = placemark.name
            ann.subtitle = placemark.locality
            
            self.locationMapView.addAnnotation(ann)
            self.locationMapView.setRegion(MKCoordinateRegionMakeWithDistance(ann.coordinate, 150.0, 150.0) ,animated:false)
        }
    }
    
    @IBAction func roadConditionButtonClick(sender: AnyObject) {
        self.locationMapView.showsTraffic = !self.locationMapView.showsTraffic
    }
    
    @IBAction func flyoverButtonClick(sender: AnyObject) {
        self.flyoverAlert()
    }
    
    @IBAction func addPitchButtonClick(sender: AnyObject) {
        self.locationMapView.camera.pitch += 10
    }
    
    @IBAction func minusButtonClick(sender: AnyObject) {
        self.locationMapView.camera.pitch -= 10
    }
    
    @IBAction func relocationButtonClick(sender: AnyObject) {
        self.locationMapView.centerCoordinate = self.currentLocation!
    }
    
    // MARK:- MKMapViewDelegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let defaultPinID = "com.piang.coordinate.pin"
        let pinView:MKPinAnnotationView = MKPinAnnotationView(annotation: annotation,reuseIdentifier: defaultPinID)
        
        pinView.pinTintColor = UIColor.redColor();
        pinView.canShowCallout = true;
        pinView.animatesDrop = true;
        
        if (annotation.coordinate.latitude != self.currentLocation?.latitude || annotation.coordinate.longitude != self.currentLocation?.longitude) {
            
            let gotoButton = UIButton(type:.System)
            gotoButton.setTitle(">", forState: UIControlState.Normal)
            gotoButton.frame = CGRectMake(0, 0, 20, 20)
            
            pinView.rightCalloutAccessoryView = gotoButton
        }
        
        return pinView;
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        self.destinationLocation = view.annotation?.coordinate
        
        self.chooseRouteWayAlert((view.annotation?.coordinate)!)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let polyLineRenderer = MKPolylineRenderer(overlay:overlay)
        polyLineRenderer.strokeColor = UIColor.blueColor()
        polyLineRenderer.lineWidth = 5;
        return polyLineRenderer
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        
        if (self.currentLocation == nil) {
            self.currentLocation = userLocation.coordinate
            self.locationMapView.centerCoordinate = self.currentLocation!
            
            locationMapView.setRegion(MKCoordinateRegionMakeWithDistance(self.currentLocation!, 150.0, 150.0) ,animated:false)
        }
    }
    
    //MARK:- AlertTViewController
    
    //MARK:-切换地图模式时，弹出选项
    func flyoverAlert() -> Void {
        
        let alertController = UIAlertController(title: "显示模式", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let cancelAction = UIAlertAction(title: "取消",style: UIAlertActionStyle.Cancel,handler: nil)
        let standardAction = UIAlertAction(title: "普通模式",style: UIAlertActionStyle.Default,handler:{
            (alertAction:UIAlertAction) -> () in
            self.locationMapView.mapType = MKMapType.Standard
        })
        let satelliteAction = UIAlertAction(title: "卫星模式",style: UIAlertActionStyle.Default,handler: {
            (alertAction:UIAlertAction) -> () in
            self.locationMapView.mapType = MKMapType.Satellite
        })
        let hybridAction = UIAlertAction(title: "混合模式",style: UIAlertActionStyle.Default,handler: {
            (alertAction:UIAlertAction) -> () in
            self.locationMapView.mapType = MKMapType.Hybrid
        })
        let satelliteFlyoverAction = UIAlertAction(title: "卫星三维模式",style: UIAlertActionStyle.Default,handler: {
            (alertAction:UIAlertAction) -> () in
            self.locationMapView.mapType = MKMapType.SatelliteFlyover
        })
        let hybridFlyoverAction = UIAlertAction(title: "混合三维模式",style: UIAlertActionStyle.Default,handler: {
            (alertAction:UIAlertAction) -> () in
            self.locationMapView.mapType = MKMapType.HybridFlyover
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(standardAction)
        alertController.addAction(satelliteAction)
        alertController.addAction(hybridAction)
        alertController.addAction(satelliteFlyoverAction)
        alertController.addAction(hybridFlyoverAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //MARK:-选择出行方式时，弹出选项
    func chooseRouteWayAlert(coordinate:CLLocationCoordinate2D) -> Void {
        let alertController = UIAlertController(title: "出行方式", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let cancelAction = UIAlertAction(title: "取消",style: UIAlertActionStyle.Cancel,handler: nil)
        let autoMobileAction = UIAlertAction(title: "驾车",style: UIAlertActionStyle.Default,handler:{
            (alertAction:UIAlertAction) -> () in
            self.planningRoute(MKDirectionsTransportType.Automobile,coordinate: coordinate)
        })
        let walkingAction = UIAlertAction(title: "步行",style: UIAlertActionStyle.Default,handler: {
            (alertAction:UIAlertAction) -> () in
            self.planningRoute(MKDirectionsTransportType.Walking,coordinate: coordinate)
        })
        let transitAction = UIAlertAction(title: "交通",style: UIAlertActionStyle.Default,handler: {
            (alertAction:UIAlertAction) -> () in
            self.planningRoute(MKDirectionsTransportType.Transit,coordinate: coordinate)
        })
        let anyAction = UIAlertAction(title: "随意",style: UIAlertActionStyle.Default,handler: {
            (alertAction:UIAlertAction) -> () in
            self.planningRoute(MKDirectionsTransportType.Any,coordinate: coordinate)
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(autoMobileAction)
        alertController.addAction(walkingAction)
        alertController.addAction(transitAction)
        alertController.addAction(anyAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //MARK:-获得出行信息，弹出提示框
    func etaInfoAlert(r:MKETAResponse) -> Void {
        
        let alertController = UIAlertController(title: "出行提示", message: "出行距离：" + (NSString(format: "%.2f公里",r.distance/1000) as String) + "\n预计时间：" + (NSString(format: "%d小时%d分",Int(r.expectedTravelTime / 3600),Int((r.expectedTravelTime % 3600)/60)) as String), preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "取消",style: UIAlertActionStyle.Cancel,handler: nil)
        let planRouteAction = UIAlertAction(title: "导航",style: UIAlertActionStyle.Default,handler:{
            (alertAction:UIAlertAction) -> () in
            self.gotoPlanningRouteAlert(r)
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(planRouteAction)
        
        self.presentViewController(alertController,animated: true,completion: nil)
    }
    
    //MARK:选择导航方式时，弹出选项
    func gotoPlanningRouteAlert(r:MKETAResponse) -> Void {
        let alertController = UIAlertController(title: "导航方式", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let cancelAction = UIAlertAction(title: "取消",style: UIAlertActionStyle.Cancel,handler: nil)
        let appleMapAction = UIAlertAction(title: "苹果地图",style: UIAlertActionStyle.Default,handler:{
            (alertAction:UIAlertAction) -> () in
            
            var launchOptions:[String : AnyObject]?
            
            if (r.transportType == MKDirectionsTransportType.Automobile) {
                launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
            }
            else if (r.transportType == MKDirectionsTransportType.Walking) {
                launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeWalking]
            }
            else if (r.transportType == MKDirectionsTransportType.Transit) {
                launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeTransit]
            }
            
            r.destination.openInMapsWithLaunchOptions(launchOptions) // 14
        })
        
        let baiduMapAction = UIAlertAction(title: "百度地图",style: UIAlertActionStyle.Default,handler:{
            (alertAction:UIAlertAction) -> () in
            
            var modelString:String?
            
            if (r.transportType == MKDirectionsTransportType.Automobile) {
                modelString = "driving"
            }
            else if (r.transportType == MKDirectionsTransportType.Walking) {
                modelString = "walking"
            }
            else if (r.transportType == MKDirectionsTransportType.Transit) {
                modelString = "transit"
            }
            
            let urlString = NSString(format: "baidumap://map/direction?origin=%f,%f&destination=%f,%f&mode=%@&src=pylocation",(self.currentLocation?.latitude)!,(self.currentLocation?.longitude)!, r.destination.placemark.coordinate.latitude, r.destination.placemark.coordinate.longitude,modelString!)
            
            UIApplication.sharedApplication().openURL(NSURL(string: urlString as String)!)
        })
        
        let gaodeMapAction = UIAlertAction(title: "高德地图",style: UIAlertActionStyle.Default,handler:{
            (alertAction:UIAlertAction) -> () in
            
            var model:Int = 0
            
            if (r.transportType == MKDirectionsTransportType.Automobile) {
                model = 0
            }
            else if (r.transportType == MKDirectionsTransportType.Walking) {
                model = 2
            }
            else if (r.transportType == MKDirectionsTransportType.Transit) {
                model = 1
            }
            
            let urlString = NSString(format: "iosamap://path?sourceApplication=pylocation&sid=currentlocation&did=destination&dlat=%f&dlon=%f&dev=0&t=%d&m=0",r.destination.placemark.coordinate.latitude,r.destination.placemark.coordinate.longitude,model)
            
            UIApplication.sharedApplication().openURL(NSURL(string: urlString as String)!)
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(appleMapAction)
        alertController.addAction(baiduMapAction)
        alertController.addAction(gaodeMapAction)
        
        self.presentViewController(alertController,animated: true,completion: nil)
    }

    
    
    func planningRoute(type:MKDirectionsTransportType,coordinate:CLLocationCoordinate2D) -> Void {
        
        let centerCoordinate = CLLocationCoordinate2DMake((self.currentLocation!.latitude + coordinate.latitude)/2, ((self.currentLocation?.longitude)! + coordinate.longitude)/2)
        
        let span = MKCoordinateSpanMake(abs(self.currentLocation!.latitude - coordinate.latitude) * 1.5, abs(self.currentLocation!.longitude - coordinate.longitude) * 1.5)
        
        locationMapView.setRegion(MKCoordinateRegionMake(centerCoordinate,span) ,animated:false)
        
        self.locationMapView.removeOverlays(self.locationMapView.overlays)
        
        let request = MKDirectionsRequest()
        let source = MKMapItem(placemark: MKPlacemark(coordinate:self.currentLocation!, addressDictionary: nil))
        request.source = source
        let destination = MKMapItem(placemark: MKPlacemark(coordinate:coordinate, addressDictionary: nil))
        request.destination = destination
        request.transportType = type
        
        let calcuteDirections = MKDirections(request: request)
        let calculateETA = MKDirections(request:request)
        
        calcuteDirections.calculateDirectionsWithCompletionHandler { (response, error) in
            if (error == nil) {
                
                for route in response!.routes {
                    self.locationMapView.addOverlay(route.polyline)
                }
            }
        }
        
        calculateETA.calculateETAWithCompletionHandler { response, error in
            if error == nil {
                if let r = response {
                    self.etaInfoAlert(r)
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
}

