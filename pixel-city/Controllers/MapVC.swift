//
//  Created by ViXette on 01/02/2018.
//

import UIKit
import MapKit
import CoreLocation


class MapVC: UIViewController, UIGestureRecognizerDelegate {

	let locationManager = CLLocationManager()
	let authStatus = CLLocationManager.authorizationStatus()
	let regionRadius = 1000.0
	
	var spinner: UIActivityIndicatorView?
	var progress_label: UILabel?
	
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var mapViewBottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var pullUpView: UIView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		locationManager.delegate = self
		
		configureLocationServices()
		
		mapView.delegate = self
		
		addDoubleTapGestureRecognizer()
	}
	
	
	func addDoubleTapGestureRecognizer () {
		let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
		doubleTapGestureRecognizer.numberOfTapsRequired = 2
		doubleTapGestureRecognizer.delegate = self
		
		mapView.addGestureRecognizer(doubleTapGestureRecognizer)
	}
	
	
	func addSwipeGestureResognizer () {
		let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
		swipeGestureRecognizer.direction = .down
		
		pullUpView.addGestureRecognizer(swipeGestureRecognizer)
	}
	
	
	func animateViewUp () {
		mapViewBottomConstraint.constant = 300
		
		UIView.animate(withDuration: 0.3) {
			self.view.layoutIfNeeded()
		}
	}
	
	
	@objc func animateViewDown () {
		mapViewBottomConstraint.constant = 0
		
		UIView.animate(withDuration: 0.3) {
			self.view.layoutIfNeeded()
		}
	}
	
	
	func addSpinner () {
		spinner = UIActivityIndicatorView()
		spinner?.center = CGPoint(
			x: (UIScreen.main.bounds.width / 2) - ((spinner?.frame.width)! / 2),
			y: (pullUpView.bounds.height / 2) - ((spinner?.frame.height)! / 2)
		)
		spinner?.activityIndicatorViewStyle = .whiteLarge
		spinner?.color = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
		
		spinner?.startAnimating()
		
		pullUpView.addSubview(spinner!)
	}
	
	
	@IBAction func centerMapButtonTapped(_ sender: UIButton) {
		if authStatus == .authorizedAlways || authStatus == .authorizedWhenInUse {
			centerMapOnUserLocation()
		}
	}

}



extension MapVC: CLLocationManagerDelegate {
	
	func configureLocationServices () {
		if authStatus == .notDetermined {
			locationManager.requestAlwaysAuthorization()
		}
	}
	
}



extension MapVC: MKMapViewDelegate {
	
	func centerMapOnUserLocation () {
		guard let coordinate = locationManager.location?.coordinate else { return }
		
		let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius, regionRadius)
		
		mapView.setRegion(coordinateRegion, animated: true)
	}
	
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		centerMapOnUserLocation()
	}
	
	
	@objc func dropPin (sender: UITapGestureRecognizer) {
		let touchPoint = sender.location(in: mapView)
		let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
		
		let annotation = DroppablePin(coordinate: touchCoordinate, id: "droppablePin")
		
		mapView.removeAnnotations(mapView.annotations)
		mapView.addAnnotation(annotation)
		
		animateViewUp()
		addSwipeGestureResognizer()
		addSpinner()
		
		mapView.setRegion(MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius, regionRadius), animated: true)
	}
	
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		if annotation is MKUserLocation {
			return nil
		}
		
		let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
		pinAnnotation.pinTintColor = #colorLiteral(red: 0.9771530032, green: 0.7062081099, blue: 0.1748393774, alpha: 1)
		pinAnnotation.animatesDrop = true
		
		return pinAnnotation
	}
	
}
