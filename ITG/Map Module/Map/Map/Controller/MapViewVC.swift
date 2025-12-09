////
////  MapViewVC.swift
////  ITG
////
////  Created by Rajpal Singh on 02/12/25.
////
//

import UIKit
import GoogleMaps
import GoogleMapsUtils
import CoreLocation

class MapViewVC: UIViewController {

    // MARK: - Map + Location
    var mapView: GMSMapView!
    let locationManager = CLLocationManager()
    var userMarker: GMSMarker?
    var routePolyline: GMSPolyline?
    var animatedMarker: GMSMarker?

    // MARK: - Clustering
    var clusterManager: GMUClusterManager!
    var allBikeItems: [BikeItem] = []
    var visibleLoadDebounce: DispatchWorkItem?
    var vehicleDetails: DetailsModel?
   
   

    // MARK: - Geofencing
    var geofenceCircle: GMSCircle?
    let geofenceCenter = CLLocationCoordinate2D(latitude: 28.6890, longitude: 77.1486)
    let geofenceRadius: CLLocationDistance = 300 // meters
    var isInsideGeofence = false
    

    // base sample coordinates
    let baseBikeCoordinates: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 28.6901, longitude: 77.1492),
        CLLocationCoordinate2D(latitude: 28.6884, longitude: 77.1478),
        CLLocationCoordinate2D(latitude: 28.6915, longitude: 77.1503),
        CLLocationCoordinate2D(latitude: 28.6872, longitude: 77.1461),
        CLLocationCoordinate2D(latitude: 28.6920, longitude: 77.1489),
        CLLocationCoordinate2D(latitude: 28.6897, longitude: 77.1512),
        CLLocationCoordinate2D(latitude: 28.6931, longitude: 77.1473),
        CLLocationCoordinate2D(latitude: 28.6869, longitude: 77.1498),
        CLLocationCoordinate2D(latitude: 28.6908, longitude: 77.1520),
        CLLocationCoordinate2D(latitude: 28.6881, longitude: 77.1456),
        CLLocationCoordinate2D(latitude: 28.6912, longitude: 77.1531),
        CLLocationCoordinate2D(latitude: 28.6876, longitude: 77.1509),
        CLLocationCoordinate2D(latitude: 28.6940, longitude: 77.1481),
        CLLocationCoordinate2D(latitude: 28.6899, longitude: 77.1449),
        CLLocationCoordinate2D(latitude: 28.6925, longitude: 77.1517)
    ]

    // geocoder instance reused
    let geocoder = CLGeocoder()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        setupLocation()
        configureBtn()
        setupGeofence()
        self.navigationController?.isNavigationBarHidden = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapView.animate(toZoom: 14)
    }

    // MARK: - Map Setup
    private func setupMap() {
        let camera = GMSCameraPosition.camera(withLatitude: geofenceCenter.latitude,
                                              longitude: geofenceCenter.longitude,
                                              zoom: 16.0)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.delegate = self

        view = mapView
        setupCluster()
        prepareBikeClusterItems(totalItems: 6000)
        loadVisibleMarkers()
    }

    // MARK: - Location Setup
    func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    // Setup Geofencing visualization
    private func setupGeofence() {
        geofenceCircle = GMSCircle(position: geofenceCenter, radius: geofenceRadius)
        geofenceCircle?.fillColor = UIColor.systemGreen.withAlphaComponent(0.15)
        geofenceCircle?.strokeColor = .systemGreen
        geofenceCircle?.strokeWidth = 2
        geofenceCircle?.map = mapView
    }

    // MARK: - Zoom Buttons UI
    private func configureBtn() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8

        let plus = UIButton(type: .system)
        plus.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        plus.addTarget(self, action: #selector(didTapZoomInBtn), for: .touchUpInside)
        plus.tintColor = .systemBlue
        plus.backgroundColor = .white
        plus.layer.cornerRadius = 20
        plus.clipsToBounds = true

        let minus = UIButton(type: .system)
        minus.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
        minus.addTarget(self, action: #selector(didTapZoomOutBtn), for: .touchUpInside)
        minus.tintColor = .systemBlue
        minus.backgroundColor = .white
        minus.layer.cornerRadius = 20
        minus.clipsToBounds = true

        stackView.addArrangedSubview(plus)
        stackView.addArrangedSubview(minus)

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -110),
            stackView.widthAnchor.constraint(equalToConstant: 44),
            stackView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }

    @objc func didTapZoomInBtn() {
        mapView.animate(toZoom: mapView.camera.zoom + 1)
    }

    @objc func didTapZoomOutBtn() {
        mapView.animate(toZoom: mapView.camera.zoom - 1)
    }
}

// MARK: - Clustering Setup & Visible Loading
extension MapViewVC {

    func setupCluster() {
        
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        clusterManager.setDelegate(self, mapDelegate: self)
    }

    func prepareBikeClusterItems(totalItems: Int = 5000) {
        allBikeItems.removeAll(keepingCapacity: true)
        let baseCount = baseBikeCoordinates.count
        guard baseCount > 0 else { return }

        for i in 0..<totalItems {
            let base = baseBikeCoordinates[i % baseCount]
            let jitterLat = Double.random(in: -0.00055...0.00055)
            let jitterLng = Double.random(in: -0.00055...0.00055)
            let pos = CLLocationCoordinate2D(latitude: base.latitude + jitterLat,
                                             longitude: base.longitude + jitterLng)
            let item = BikeItem(position: pos, bikeId: "bike-\(i)")
            allBikeItems.append(item)
        }
    }

    func loadVisibleMarkers() {
        visibleLoadDebounce?.cancel()

        let work = DispatchWorkItem { [weak self] in
            guard let self = self, let map = self.mapView else { return }

            let visible = map.projection.visibleRegion()
            var bounds = GMSCoordinateBounds(region: visible)
            bounds = bounds.expanded(factor: 0.30)
            self.clusterManager.clearItems()
            var added = 0
            for item in self.allBikeItems {
                if bounds.contains(item.position) {
                    self.clusterManager.add(item)
                    added += 1
                }
            }
            self.clusterManager.cluster()
        }

        visibleLoadDebounce = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: work)
    }
}

// MARK: - Location Delegate
extension MapViewVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }

        if userMarker == nil {
            userMarker = GMSMarker(position: loc.coordinate)
            userMarker?.icon = UIImage(named: "user") ?? GMSMarker.markerImage(with: .blue)
            userMarker?.title = "You"
            userMarker?.map = mapView
        } else {
            userMarker?.position = loc.coordinate
        }

        // ----- GEO-FENCE CHECK -----
        let userLocation = CLLocation(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
        let center = CLLocation(latitude: geofenceCenter.latitude, longitude: geofenceCenter.longitude)
        let distance = userLocation.distance(from: center)

        if distance <= geofenceRadius {
            if isInsideGeofence == false {
                isInsideGeofence = true
                print("Entered Geofence")
                showGeofenceAlert(title: "Inside Zone", msg: "You entered to ITG Region")
            }
        } else {
            if isInsideGeofence == true {
                isInsideGeofence = false
                print("Exited Geofence")
               showGeofenceAlert(title: "Outside Zone", msg: "You exited the green zone")
            }
        }
    }
}

// MARK: - GMSMapViewDelegate + cluster tap handling
extension MapViewVC: GMSMapViewDelegate, GMUClusterManagerDelegate, GMUClusterRendererDelegate {

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        loadVisibleMarkers()
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {

        if let cluster = marker.userData as? GMUCluster {
            let currentZoom = mapView.camera.zoom
            let nextZoom = min(currentZoom + 2.0, mapView.maxZoom)
            mapView.animate(with: GMSCameraUpdate.setTarget(cluster.position, zoom: nextZoom))
            return true
        }

    
        if let bike = marker.userData as? BikeItem {
            
            let bikeCoord = bike.position
            let insideFence = isMarkerInsideGeofence(markerCoord: bikeCoord, fenceCenter: geofenceCenter, radius: geofenceRadius)

            if insideFence {
                reverseGeocode(lat: geofenceCenter.latitude, lng: geofenceCenter.longitude) { [weak self] address in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        marker.title = "Inside Geofence"
                        marker.snippet = "ITG"
                        self.mapView.selectedMarker = marker
                    }
                }
            } else {
                reverseGeocode(lat: bikeCoord.latitude, lng: bikeCoord.longitude) { [weak self] address in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        marker.title = "Bike Location"
                        marker.snippet = "Location: \(self.formatCoordinateString(bikeCoord))\n\(address)"
                        self.mapView.selectedMarker = marker
                    }
                }
            }

            drawRouteAndShowAddressLess(to: bikeCoord, forMarker: marker)

            return true
        }
        

        
        
        return false
    }

    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        if let _ = marker.userData as? GMUCluster {
        } else if let _ = marker.userData as? BikeItem {
            marker.icon = UIImage(named: "bike") ?? GMSMarker.markerImage(with: .red)
            marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        }
    }
}

// MARK: - Directions, polyline draw, animate (but InfoWindow content handled by reverse geocode)
extension MapViewVC {

    func drawRouteAndShowAddressLess(to bikeCoord: CLLocationCoordinate2D, forMarker marker: GMSMarker) {
        guard let userCoord = userMarker?.position else { return }

        getRouteFromGoogle(from: userCoord, to: bikeCoord) { [weak self] path, distance, duration in
            guard let self = self, let path = path else { return }
            
            var speedText = ""
            if let distance = distance, let duration = duration {
                
                let distKm = self.parseDistanceToKm(distance)
                let timeHours = self.parseDurationToHours(duration)
                if distKm > 0 && timeHours > 0 {
                    let speed = distKm / timeHours
                    speedText = String(format: " | Speed: %.1f km/h", speed)
                }
            }
            
            vehicleDetails = DetailsModel(speed: speedText, distance: distance ?? "")
            DispatchQueue.main.async {
                self.openVehicleDetailPopUp()
            }
            
            DispatchQueue.main.async {
                self.routePolyline?.map = nil
                self.animatedMarker?.map = nil

                let polyline = GMSPolyline(path: path)
                self.routePolyline = polyline
                polyline.strokeWidth = 6
                polyline.strokeColor = .systemBlue
                polyline.map = self.mapView
                self.mapView.animate(toLocation: bikeCoord)
                self.animateBikeAlongPath(path: path, markerTitle: marker.title)
            }
        }
    }
    

    /// Directions API call to Google Directions. Keep your key in SdkConstants.apiKey
    func getRouteFromGoogle(from: CLLocationCoordinate2D,
                            to: CLLocationCoordinate2D,
                            completion: @escaping (GMSPath?, String?, String?) -> Void) {

        guard !SdkConstants.apiKey.isEmpty else {
            completion(nil, nil, nil)
            return
        }

        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(from.latitude),\(from.longitude)&destination=\(to.latitude),\(to.longitude)&mode=driving&key=\(SdkConstants.apiKey)"
        guard let url = URL(string: urlString) else {
            completion(nil, nil, nil); return
        }

        URLSession.shared.dataTask(with: url) { data, resp, err in
            guard let data = data else { completion(nil, nil, nil); return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String:Any],
                   let route = (json["routes"] as? [[String:Any]])?.first,
                   let poly = route["overview_polyline"] as? [String:Any],
                   let points = poly["points"] as? String,
                   let leg = (route["legs"] as? [[String:Any]])?.first {

                    let distance = (leg["distance"] as? [String:Any])?["text"] as? String
                    let duration = (leg["duration"] as? [String:Any])?["text"] as? String

                    if let path = GMSPath(fromEncodedPath: points) {
                        completion(path, distance, duration)
                        return
                    }
                }
                completion(nil, nil, nil)
            } catch {
                print("Directions parse error:", error)
                completion(nil, nil, nil)
            }
        }.resume()
    }

    func animateBikeAlongPath(path: GMSPath, markerTitle: String?) {
        if animatedMarker == nil {
            animatedMarker = GMSMarker()
            animatedMarker?.icon = UIImage(named: "bike") ?? GMSMarker.markerImage(with: .red)
        }
        animatedMarker?.title = markerTitle
        animatedMarker?.map = self.mapView

        let totalSteps = 200
        let durationSeconds = 10.0
        let stepTime = durationSeconds / Double(totalSteps)

        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            for i in 0...totalSteps {
                let t = Double(i) / Double(totalSteps)
                let coord = path.position(at: t)
                DispatchQueue.main.async {
                    self.animatedMarker?.position = coord
                    self.animatedMarker?.title = markerTitle
                }
                Thread.sleep(forTimeInterval: stepTime)
            }

            DispatchQueue.main.async {
                // remove animated marker when finished
                self.animatedMarker?.map = nil
            }
        }
    }

    func parseDistanceToKm(_ text: String) -> Double {
        let lower = text.lowercased().trimmingCharacters(in: .whitespaces)
        if lower.contains("km") {
            let s = lower.replacingOccurrences(of: "km", with: "").trimmingCharacters(in: .whitespaces)
            return Double(s) ?? 0.0
        } else if lower.contains("m") {
            let s = lower.replacingOccurrences(of: "m", with: "").trimmingCharacters(in: .whitespaces)
            if let meters = Double(s) {
                return meters / 1000.0
            }
            return 0.0
        } else {
            return Double(lower) ?? 0.0
        }
    }

    func parseDurationToHours(_ text: String) -> Double {
        let lower = text.lowercased()
        if lower.contains("hour") || lower.contains("hr") {
            let parts = lower.components(separatedBy: " ")
            var hours = 0.0
            var mins = 0.0
            for (i, p) in parts.enumerated() {
                if p.contains("hour") || p.contains("hr") {
                    if i > 0, let v = Double(parts[i-1]) { hours = v }
                } else if p.contains("min") {
                    if i > 0, let v = Double(parts[i-1]) { mins = v }
                }
            }
            return hours + (mins / 60.0)
        } else if lower.contains("min") {
            let num = lower.replacingOccurrences(of: "mins", with: "").replacingOccurrences(of: "min", with: "").trimmingCharacters(in: .whitespaces)
            let mins = Double(num) ?? 0.0
            return mins / 60.0
        } else {
            return 0.0
        }
    }
}

// MARK: - Geocode + helpers
extension MapViewVC {

    func isMarkerInsideGeofence(markerCoord: CLLocationCoordinate2D, fenceCenter: CLLocationCoordinate2D, radius: CLLocationDistance) -> Bool {
        let markerLocation = CLLocation(latitude: markerCoord.latitude, longitude: markerCoord.longitude)
        let centerLocation = CLLocation(latitude: fenceCenter.latitude, longitude: fenceCenter.longitude)
        let distance = markerLocation.distance(from: centerLocation)
        return distance <= radius
    }

    func reverseGeocode(lat: Double, lng: Double, completion: @escaping (String) -> Void) {
        if geocoder.isGeocoding {
            geocoder.cancelGeocode()
        }

        let location = CLLocation(latitude: lat, longitude: lng)
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                let components: [String?] = [
                    placemark.name,
                    placemark.thoroughfare,
                    placemark.subThoroughfare,
                    placemark.subLocality,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.postalCode,
                    placemark.country
                ]

                let address = components.compactMap { $0 }.joined(separator: ", ")
                if address.isEmpty {
                    completion("Address not available")
                } else {
                    completion(address)
                }
            } else {
                completion("Address not available")
            }
        }
    }

    func formatCoordinateString(_ coord: CLLocationCoordinate2D) -> String {
        return String(format: "%.5f, %.5f", coord.latitude, coord.longitude)
    }

   
}

// MARK: - Helper: BikeItem model
class BikeItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var bikeId: String

    init(position: CLLocationCoordinate2D, bikeId: String) {
        self.position = position
        self.bikeId = bikeId
    }
}

// MARK: - Extensions

extension GMSCoordinateBounds {
    func expanded(factor: Double) -> GMSCoordinateBounds {
        let ne = self.northEast
        let sw = self.southWest
        let latSpan = abs(ne.latitude - sw.latitude)
        let lngSpan = abs(ne.longitude - sw.longitude)

        let expandLat = latSpan * factor
        let expandLng = lngSpan * factor

        let newNE = CLLocationCoordinate2D(latitude: ne.latitude + expandLat, longitude: ne.longitude + expandLng)
        let newSW = CLLocationCoordinate2D(latitude: sw.latitude - expandLat, longitude: sw.longitude - expandLng)
        return GMSCoordinateBounds(coordinate: newNE, coordinate: newSW)
    }

    func contains(_ coordinate: CLLocationCoordinate2D) -> Bool {
        return (coordinate.latitude <= northEast.latitude && coordinate.latitude >= southWest.latitude)
            && (coordinate.longitude <= northEast.longitude && coordinate.longitude >= southWest.longitude)
    }
}

extension GMSPath {
    func position(at fraction: Double) -> CLLocationCoordinate2D {
        let count = Int(self.count())
        if count < 2 { return self.coordinate(at: 0) }

        var distances: [Double] = []
        var total: Double = 0
        for i in 0..<(count - 1) {
            let a = self.coordinate(at: UInt(i))
            let b = self.coordinate(at: UInt(i + 1))
            let d = CLLocation(latitude: a.latitude, longitude: a.longitude).distance(from: CLLocation(latitude: b.latitude, longitude: b.longitude))
            distances.append(d)
            total += d
        }
        if total <= 0 { return self.coordinate(at: 0) }

        let target = total * max(0.0, min(1.0, fraction))
        var cum: Double = 0
        for i in 0..<distances.count {
            if cum + distances[i] >= target {
                let segTarget = (target - cum) / distances[i]
                let a = self.coordinate(at: UInt(i))
                let b = self.coordinate(at: UInt(i + 1))
                let lat = a.latitude + (b.latitude - a.latitude) * segTarget
                let lng = a.longitude + (b.longitude - a.longitude) * segTarget
                return CLLocationCoordinate2D(latitude: lat, longitude: lng)
            }
            cum += distances[i]
        }
        return self.coordinate(at: UInt(count - 1))
    }
}

//MARK: - open another controller on map
extension MapViewVC {
    func openVehicleDetailPopUp() {
        let storyboard = UIStoryboard(name: "MapViewVC", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "VehicleDetailsPopup") as! VehicleDetailsPopup
        mapVC.modalPresentationStyle = .overCurrentContext
        mapVC.details = self.vehicleDetails
        present(mapVC, animated: true)
    }
}


