//
//  ImagesViewController.swift
//  VirtualTourist
//
//  Created by Abdullah Aldakhiel on 29/01/2019.
//  Copyright © 2019 Abdullah Aldakhiel. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ImagesViewController: UIViewController, MKMapViewDelegate{

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
  
    var dataController: DataController {
        return DataController.shared
    }
    var selectedIndexes = [IndexPath]()
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    var totalPages: Int? = nil
    
    var presentingAlert = false
    var pin: Pins?
    var fetchedResultsController: NSFetchedResultsController<Photo>!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        guard let pin = pin else {
            return
        }
        setMap(pin)
        setupPhotos(pin)
        
        if let photos = pin.photos, photos.count == 0 {
            fetchPhotosFromAPI(pin)
        }
    }
    private func setMap(_ pin: Pins) {
        let location = CLLocationCoordinate2D(latitude: pin.lat,longitude: pin.long)
        let bound = MKCoordinateSpan(latitudeDelta: 1.20, longitudeDelta: 1.20)
        let region = MKCoordinateRegion(center: location, span: bound)
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.long)
        self.mapView.addAnnotation(annotation)
    }

    @IBAction func deleteAction(_ sender: Any) {
        for photos in fetchedResultsController.fetchedObjects! {
            dataController.viewContext.delete(photos)
        }
        try? dataController.viewContext.save()
        fetchPhotosFromAPI(pin!)
    }
    private func setupPhotos(_ pin: Pins) {
        
        let fr: NSFetchRequest<Photo> = Photo.fetchRequest()
        fr.sortDescriptors = []
        fr.predicate = NSPredicate(format: "pin == %@", argumentArray: [pin])
                fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
                var error: NSError?
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
        }
    }
    
    private func fetchPhotosFromAPI(_ pin: Pins) {
        
        let lat = pin.lat
        let lon = pin.long
        
        Connect.shared().searchBy(latitude: lat, longitude: lon, totalPages: totalPages) { (photosParsed, error) in


            if let photosParsed = photosParsed {
                self.totalPages = photosParsed.photos.pages
                let totalPhotos = photosParsed.photos.photo.count
                self.storePhotos(photosParsed.photos.photo, forPin: pin)
                if totalPhotos == 0 {
                    self.updateStatusLabel("No Photo")
  

                }
            } else if let error = error {
                self.updateStatusLabel("Error")
            }
        }
    }
    
    private func updateStatusLabel(_ text: String) {
            self.label.text = text
        }
    
    
    private func storePhotos(_ photos: [PhotoParser], forPin: Pins) {
        for photo in photos {
            
                if let url = photo.url {

                    let managedObject = Photo(context: DataController.shared.viewContext)
                    managedObject.photo = url
                    managedObject.pin = forPin
                    try? DataController.shared.viewContext.save()
                   // images.flickrPhotos.append(url)
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            
        }
    }
    
}
extension ImagesViewController {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
}

extension ImagesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width - 1) / 3
        return CGSize(width: width, height: width)
    }

    
}

extension ImagesViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {
        
        switch (type) {
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .update:
            updatedIndexPaths.append(indexPath!)
            break
        case .move:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItems(at: [indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItems(at: [indexPath])
            }
            
        }, completion: nil)
    }
    
}

extension ImagesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sectionInfo = self.fetchedResultsController.sections?[section] {
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoViewCell.identifier, for: indexPath) as! PhotoViewCell
        cell.imageView.image = nil
        cell.activityIndicator.startAnimating()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photo = fetchedResultsController.object(at: indexPath)
        let photoViewCell = cell as! PhotoViewCell
        photoViewCell.imageUrl = photo.photo!
        configImage(using: photoViewCell, photo: photo, collectionView: collectionView, index: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(photoToDelete)
        try? dataController.viewContext.save()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying: UICollectionViewCell, forItemAt: IndexPath) {
        
        if collectionView.cellForItem(at: forItemAt) == nil {
            return
        }
        
        let photo = fetchedResultsController.object(at: forItemAt)
        if let imageUrl = photo.photo {
            Connect.shared().cancelDownload(imageUrl)
        }
    }

    private func configImage(using cell: PhotoViewCell, photo: Photo, collectionView: UICollectionView, index: IndexPath) {
        if let imageData = photo.imagedata {
            cell.activityIndicator.stopAnimating()
            cell.imageView.image = UIImage(data: imageData)
        } else {
            if let imageUrl = photo.photo {
                cell.activityIndicator.startAnimating()
                Connect.shared().downloadImage(imageUrl: imageUrl) { (data, error) in
                    if let _ = error {
                        return
                    } else if let data = data {
                        
                        
                        if let currentCell = collectionView.cellForItem(at: index) as? PhotoViewCell {
                            if currentCell.imageUrl == imageUrl {
                                currentCell.imageView.image = UIImage(data: data)
                                cell.activityIndicator.stopAnimating()
                            }
                        }
                        photo.imagedata = data
                        DispatchQueue.global(qos: .background).async {
                            try? self.dataController.viewContext.save()
                        }
                        
                    }
                }
            }
        }
    }
    
    
}
