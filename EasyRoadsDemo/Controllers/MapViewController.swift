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
    var placesView: PlacesView!
    
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
    
    
    // custom marker info window
    var customMarkerInfoWindow: CustomMarkerInfoWindow!
    var tappedMarker: GMSMarker!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        initLocationManager()
        
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
        
        setupPlacesView()
        
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
        
        var latitude = 19.2822056
        var longituge = 72.8590269
        
        if let lat = self.locationManager.location?.coordinate.latitude, let long = self.locationManager.location?.coordinate.longitude {
            latitude = lat
            longituge = long
        }
        
        
        let cameraPosition = GMSCameraPosition.camera(withLatitude: latitude, longitude: longituge, zoom: 10.0)
        //let cameraPosition = GMSCameraPosition.camera(withLatitude: (self.locationManager.location?.coordinate.latitude)!, longitude: (self.locationManager.location?.coordinate.longitude)!, zoom: 10.0)
        
        
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
    
    func setupPlacesView() {
        placesView = PlacesView(frame: CGRect(x: (UIScreen.main.bounds.width - (60 + 8)) * -1, y: UIApplication.shared.statusBarFrame.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height))
        
        self.view.addSubview(placesView)
        placesView.delegate = self
        
        
        placesView.locations = locations
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
        
        placesView.locations = locations
        
        // show driving directions
        if locations.count > 1 {
            //showDirections(optimization: searchView.optimizedState)
            
            // UN-COMMENT AFTER TESTING
            self.showDirections(optimization: OptimizationState.dontShow)
            
        }
        
    }
    
    func showDirections(optimization: OptimizationState) {
        
        if optimization == OptimizationState.show {
            
            if let originlocation = locations.first, let destinationLocation = locations.last {
                
                let origin = "\(originlocation.placeLocation.coordinate.latitude),\(originlocation.placeLocation.coordinate.longitude)"
                
                let destination = "\(destinationLocation.placeLocation.coordinate.latitude),\(destinationLocation.placeLocation.coordinate.longitude)"
                
                var waypointString = "waypoints=optimize:true"
                
                for i in 0..<locations.count {
                    if let location = locations[i] as? Location {
                        waypointString.append("|\(location.placeLocation.coordinate.latitude),\(location.placeLocation.coordinate.longitude)")
                    }
                }
                
                
                var urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&alternatives=false&\(waypointString)&key=AIzaSyCkU0sahc_2l7Viy9dlQDxwkOkDnt24OMk"
                print("\n\(urlString)\n")
                
                
                let allowedCharacterSet = (CharacterSet(charactersIn: "|").inverted)
                
                guard let escapedString = urlString.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)  else {
                    return
                }

                
                guard let url = URL(string: escapedString) else {
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
                
            } else {
                return
            }
            
        } else {
            
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
                                
                                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary
                                let routes = json!["routes"] as! [[String: Any]]
                                
                                for route in routes {
                                    
                                    DispatchQueue.main.async {
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
        
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

// MARK:- GMSMapView Delegate

extension MapViewController: GMSMapViewDelegate {
    
    /*func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        let view = CustomMarkerInfoWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 80), marker: marker, title: marker.title!)
        view.delegate = self
        return view
    }*/
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        if marker.title != "Current Location" {
            
            if let customInfoWindow = customMarkerInfoWindow {
                customInfoWindow.removeFromSuperview()
            }
            
            tappedMarker = marker
            
            customMarkerInfoWindow = CustomMarkerInfoWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 110), marker: marker, title: marker.title!)
            self.view.addSubview(customMarkerInfoWindow)
            customMarkerInfoWindow.delegate = self
            
            customMarkerInfoWindow.center = CGPoint(x: mapView.projection.point(for: marker.position).x, y: mapView.projection.point(for: marker.position).y - 80) //mapView.projection.point(for: marker.position)
            
        }
        
        
        
        

        /*if marker.title != "Current Location" {
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
                
                if locations.count > 1 {
                    //self.showDirections(optimization: searchView.optimizedState)
                    self.showDirections(optimization: OptimizationState.dontShow)
                }
                
            }
        }*/
        
        return true
    }
    
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if let marker = tappedMarker {
            let newPoint = CGPoint(x: mapView.projection.point(for: marker.position).x, y: mapView.projection.point(for: marker.position).y - 80)
            customMarkerInfoWindow.center = newPoint//mapView.projection.point(for: marker.position)
        }
    }    
}


// MARK:- CustomMarkerInfoWindow Delegate

extension MapViewController: CustomMarkerInfoWindowDelegate {
    
    func removeMarkerInfoWindow(_ sender: CustomMarkerInfoWindow, marker: GMSMarker) {
        print("remove marker from map")
        
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
            
            
            placesView.locations = locations
            
            if locations.count > 1 {
                //self.showDirections(optimization: searchView.optimizedState)
                self.showDirections(optimization: OptimizationState.dontShow)
            }
            
        }
        
        if let customInfoWindow = customMarkerInfoWindow {
            customInfoWindow.removeFromSuperview()
        }
    }
    
    func closeMarkerInfoWindow(_ sender: CustomMarkerInfoWindow, marker: GMSMarker) {
        print("close marker from map")
        
        if let customInfoWindow = customMarkerInfoWindow {
            customInfoWindow.removeFromSuperview()
        }
    }
}

// MARK:- SearchView Delegate

extension MapViewController: SearchViewDelegate {
    
    
    func clearMap(sender: SearchView) {
        self.locations.removeAll()
        self.googleMapView.clear()
        self.currentLocationDetected = false
        
        placesView.locations = locations
        
        self.locationManager.startUpdatingLocation()
        
        // to close the slider
        self.sliderTapped(sender: sender, state: SliderState.SliderStateClosed)
    }
    
    func optimizeRoutes(sender: SearchView, optimization: OptimizationState) {
        
        if locations.count > 1 {
            //showDirections(optimization: optimization)
            showDirections(optimization: OptimizationState.dontShow)
        }
        
        
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
                
                self.placesView.frame = CGRect(x: -UIScreen.main.bounds.width, y: UIApplication.shared.statusBarFrame.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height)
            }, completion: { (finished) in
                self.searchView.state = SliderState.SliderStateOpened
                self.searchView.showKeyboard()
            })
        } else {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
                self.searchView.frame = CGRect(x: UIScreen.main.bounds.width - 60 - 8, y: UIApplication.shared.statusBarFrame.height, width: UIScreen.main.bounds.width - 10, height: UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height)
                
                self.placesView.frame = CGRect(x: (UIScreen.main.bounds.width - (60 + 8)) * -1, y: UIApplication.shared.statusBarFrame.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height)
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

// MARK:- PlacesView Delegate

extension MapViewController: PlacesViewDelegate {
    
    func sliderTapped(sender: PlacesView, state: SliderState) {
        if state == SliderState.SliderStateOpened {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
                self.placesView.frame = CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height)
                
                self.searchView.frame = CGRect(x: UIScreen.main.bounds.width, y: UIApplication.shared.statusBarFrame.height, width: UIScreen.main.bounds.width - 10, height: UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height)
            }, completion: { (finished) in
                self.placesView.state = SliderState.SliderStateOpened
            })
        } else {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
                self.placesView.frame = CGRect(x: (UIScreen.main.bounds.width - (60 + 8)) * -1, y: UIApplication.shared.statusBarFrame.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height)
                
                self.searchView.frame = CGRect(x: UIScreen.main.bounds.width - 60 - 8, y: UIApplication.shared.statusBarFrame.height, width: UIScreen.main.bounds.width - 10, height: UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height)
            }, completion: { (finished) in
                self.placesView.state = SliderState.SliderStateClosed
            })
            
        }
    }
    
    func placeRemoved(sender: PlacesView, location: Location) {
        
        if let marker = location.marker {
            
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
                
                
                placesView.locations = locations
                
                if locations.count > 1 {
                    //self.showDirections(optimization: searchView.optimizedState)
                    self.showDirections(optimization: OptimizationState.dontShow)
                }
                
            }
            
        }
        
    }
  
}

// MARK:- CLLocationManager Delegate

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
