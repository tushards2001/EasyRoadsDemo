//
//  MapViewController.swift
//  EasyRoadsDemo
//
//  Created by MacBookPro on 4/3/18.
//  Copyright © 2018 basicdas. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import GooglePlaces
import Reachability


class MapViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    var currentLocationDetected: Bool = false
    
    var searchView: SearchView!
    
    var googleMapView: GMSMapView!
    //var cameraPosition = GMSCameraPosition()
    
    // locations array
    var locationsArray = [CLLocation]()
    var locations = [Location]()
    var polyLines = [GMSPolyline]()
    
    // rechability
    let reachability = Reachability()!
    
    // offline
    var offlineView: OfflineView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
        initLocationManager()
        
        //showCurrentLocationOnMap()
        
        
        setupStatusBar()
        
        
        
    }
    
    func showOfflineView() {
        if offlineView == nil {
            let frameRect = CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height)
            offlineView = OfflineView(frame: frameRect)
            offlineView.alpha = 0
            self.view.addSubview(offlineView)
            UIView.animate(withDuration: 0.3, animations: {
                self.offlineView.alpha = 1
            }, completion: { (finished) in
                //
            })
        } else {
            print("OfflineView already added")
        }
    }
    
    func removeOfflineView() {
        if offlineView != nil {
            if offlineView.isDescendant(of: self.view) {
                UIView.animate(withDuration: 0.3, animations: {
                    self.offlineView.alpha = 0
                }, completion: { (finished) in
                    self.offlineView.removeFromSuperview()
                    self.offlineView = nil
                })
            } else {
                print("OfflineView not available")
            }
        }
        
    }
    
    @objc func reachabilityChanged(notification: Notification) {
        let reach = notification.object as! Reachability
        
        switch reach.connection {
        case .wifi:
            print("WiFi Connection")
            removeOfflineView()
            
        case .cellular:
            print("Cellular Connection")
            removeOfflineView()
            
        case .none:
            print("No Connection")
            showOfflineView()
            
        default:
            ()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupSearchView()
        
        // reachability notifier
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(notification:)), name: .reachabilityChanged, object: nil)
        
        do {
            try reachability.startNotifier()
        } catch let error {
            print("Error: Could not start reachability notifier. (\(error)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }
    
    func initLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    
    func showCurrentLocationOnMap() {
        
        let cameraPosition = GMSCameraPosition.camera(withLatitude: (self.locationManager.location?.coordinate.latitude)!, longitude: (self.locationManager.location?.coordinate.longitude)!, zoom: 10.0)
        
        
        if googleMapView == nil {
            googleMapView = GMSMapView.map(withFrame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height), camera: cameraPosition)
            googleMapView.delegate = self
            view.addSubview(googleMapView)
        }
        
        googleMapView.animate(to: cameraPosition)
        
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = cameraPosition.target
        marker.title = "Current Location"
        marker.snippet = "You are here"
        marker.appearAnimation = .pop
        marker.icon = GMSMarker.markerImage(with: UIColor.green)
        marker.map = googleMapView //mapView

        
        let location = Location(withLocation: CLLocation(latitude: marker.position.latitude, longitude: marker.position.longitude), mapMarker: marker)
        locations.append(location)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func setupStatusBar() {
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        let statusBarColor = UIColor(red: 44.0/255.0, green: 79.0/255.0, blue: 111.0/255.0, alpha: 1.0)
        statusBarView.backgroundColor = statusBarColor
        view.addSubview(statusBarView)
    }
    
    func setupSearchView() {
        searchView = SearchView(frame: CGRect(x: UIScreen.main.bounds.width - 60 - 8, y: UIApplication.shared.statusBarFrame.height, width: UIScreen.main.bounds.width - 10, height: UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height))
        self.view.addSubview(searchView)
        searchView.delegate = self
        
    }
    
    func putDestinationMarker(coordinates: CLLocationCoordinate2D, placeName: String) {
        print("Place = \(placeName)")
        print("Latitude = \(coordinates.latitude) | Longitude = \(coordinates.longitude)")
        
        let loc = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        locationsArray.append(loc)
        
        let cameraPosition = GMSCameraPosition.camera(withLatitude: coordinates.latitude, longitude: coordinates.longitude, zoom: 10.0)
        /*let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: cameraPosition)
        view = mapView*/
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
        marker.title = placeName
        marker.map = googleMapView
        
        googleMapView.camera = cameraPosition
        
        
        // append to location array
        let location = Location(withLocation: CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude), mapMarker: marker)
        locations.append(location)
        
        
        // show driving directions
        showDirections()
    }
    
    func showDirections() {
        
        for i in 0..<locations.count {
            
            if (i+1) < locations.count {
                let originlocation = locations[i]
                let destinationLocation = locations[i+1]
                
                let origin = "\(originlocation.placeLocation.coordinate.latitude),\(originlocation.placeLocation.coordinate.longitude)"
                let destination = "\(destinationLocation.placeLocation.coordinate.latitude),\(destinationLocation.placeLocation.coordinate.longitude)"
                //let optimizeString = "optimize:true|\(origin)|\(destination)"
                
                let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&alternatives=false"
                print("\n\(urlString)\n")
                
                guard let url = URL(string: urlString) else {
                    print("Error: Cannot create URL")
                    return
                }
                
                let urlRequest = URLRequest(url: url)
                let config = URLSessionConfiguration.default
                let session = URLSession(configuration: config)
                
                let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
                    
                    if error != nil {
                        print("Error: \(error!)")
                    } else {
                        do {
                            //let json = try JSONSerialization.data(withJSONObject: data, options: []) as? NSDictionary
                            let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary
                            let routes = json!["routes"] as! [[String: Any]]
                            
                            for route in routes {
                                let routeOverviewPolyline = route["overview_polyline"] as! [String: Any]
                                let points = routeOverviewPolyline["points"] as! String
                                let path = GMSPath.init(fromEncodedPath: points)
                                
                                let polyline = GMSPolyline.init(path: path)
                                polyline.strokeWidth = 4
                                polyline.strokeColor = UIColor.rgb(red: 0, green: 179, blue: 253)
                                polyline.map = self.googleMapView
                                
                                self.polyLines.append(polyline)
                                //destinationLocation.polyLine = polyline
                            }
                        } catch let err {
                            print("JSON Error: \(err)")
                        }
                    }
                    
                })
                
                task.resume()
            }
            
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

extension MapViewController: GMSMapViewDelegate {
    
    /*func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        let view = CustomMarkerInfoWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 80), marker: marker, title: marker.title!)
        view.delegate = self
        return view
    }*/
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if marker.title != "Current Location" {
            marker.map = nil
            
            var index: Int = -1
            
            for i in 0..<locations.count {
                let location = locations[i]
                if location.marker == marker {
                    index = i
                    //break
                }
                
                if let polyLine = location.polyLine {
                    polyLine.map = nil
                }
            }
            
            // remove all route drawings
            for polyLine in polyLines {
                polyLine.map = nil
            }
            
            polyLines.removeAll()
            
            
            
            
            // remove location from locations array
            if index > -1 {
                locations.remove(at: index)
                //self.googleMapView.clear()
                
                self.showDirections()
            }
        }
        
        return true
    }
    
}

extension MapViewController: CustomMarkerInfoWindowDelegate {
    
    func removeMarkerInfoWindow(_ sender: CustomMarkerInfoWindow, marker: GMSMarker) {
        marker.map = nil
    }
    
}

extension MapViewController: SearchViewDelegate {
    
    
    func clearMap(sender: SearchView) {
        self.locations.removeAll()
        self.googleMapView.clear()
        self.currentLocationDetected = false
        self.locationManager.startUpdatingLocation()
        
        // to close the slider
        self.sliderTapped(sender: sender, state: SliderState.SliderStateClosed)
    }
    
    
    
    
    func predictionSelected(sender: SearchView, prediction: GMSAutocompletePrediction) {
        /*print("----------------- show place ------------------")
        print("Name: \(prediction.attributedPrimaryText.string)")
        print("ID: \(prediction.placeID!)")*/
        
        let placeClient = GMSPlacesClient()
        
        placeClient.lookUpPlaceID(prediction.placeID!) { (place, error) in
            if error != nil {
                print("Error: \(String(describing: error))")
            } else {
                if let coordinates = place?.coordinate {
                    // show place on map with marker
                    self.putDestinationMarker(coordinates: coordinates, placeName: prediction.attributedPrimaryText.string)
                    
                    // to close the slider
                    self.sliderTapped(sender: sender, state: SliderState.SliderStateClosed)
                }
            }
        }
    }
    
    func sliderTapped(sender: SearchView, state: SliderState) {
        if state == SliderState.SliderStateOpened {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
                self.searchView.frame = CGRect(x: 10, y: UIApplication.shared.statusBarFrame.height, width: UIScreen.main.bounds.width - 10, height: UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height)
            }, completion: { (finished) in
                self.searchView.state = SliderState.SliderStateOpened
                self.searchView.showKeyboard()
            })
        } else {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
                self.searchView.frame = CGRect(x: UIScreen.main.bounds.width - 60 - 8, y: UIApplication.shared.statusBarFrame.height, width: UIScreen.main.bounds.width - 10, height: UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height)
            }, completion: { (finished) in
                self.searchView.state = SliderState.SliderStateClosed
                self.searchView.dismissKeyboard()
            })
            
        }
    }
    
    func searchBarTextChanged(sender: SearchView, searchString: String) {
        print("\(searchString)")
        
        let placeClient = GMSPlacesClient()
        placeClient.autocompleteQuery(searchString, bounds: nil, filter: nil) { (results, error) in
            if error != nil {
                print("Error: \(String(describing: error))")
            } else {
                DispatchQueue.main.async {
                    self.searchView.updatePredictionsData(withArray: results!)
                }
                
                /*for result in results! {
                    if let result = result as? GMSAutocompletePrediction {
                        print("\(result)")
                        //print("\(result.attributedFullText.string)")
                        //print("\(String(describing: result.placeID))")
                    }
                }*/
            }
        }
    }
    
    
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if !currentLocationDetected {
            currentLocationDetected = true
            
            locationsArray.append(locations[0])
            
            manager.stopUpdatingLocation()
            self.showCurrentLocationOnMap()
        }
        
    }
    
}
