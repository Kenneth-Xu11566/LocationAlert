// ViewController.swift
// LocationAwareNotificationApp

import UIKit
import CoreLocation
import UserNotifications

class ViewController: UIViewController, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {

    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        UNUserNotificationCenter.current().delegate = self
        requestPermissions()
    }

    func requestPermissions() {
        locationManager.requestAlwaysAuthorization()
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            // Handle the error if needed
        }
    }

    func setupGeofenceForAnnArbor() {
        let annArborCenter = CLLocationCoordinate2D(latitude: 42.2808, longitude: -83.7430)
        let regionRadius = 5000.0 // 5km radius
        
        let geofenceRegion = CLCircularRegion(center: annArborCenter, radius: regionRadius, identifier: "AnnArbor")
        geofenceRegion.notifyOnExit = true
        geofenceRegion.notifyOnEntry = false
        
        locationManager.startMonitoring(for: geofenceRegion)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedAlways {
            setupGeofenceForAnnArbor()
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region.identifier == "AnnArbor" {
            sendNotification()
        }
    }

    func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Location Alert"
        content.body = "You have left Ann Arbor!"
        content.sound = .default

        let request = UNNotificationRequest(identifier: "locationAlert", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            }
        }
    }

    // MARK: UNUserNotificationCenterDelegate Methods
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
