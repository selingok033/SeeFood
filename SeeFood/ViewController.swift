//
//  ViewController.swift
//  SeeFood
//
//  Created by Selin Gök on 13.05.2022.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var predictionLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera //.photoLibrary for selecting any photo from user's photo album.
        imagePicker.allowsEditing = false // true : allows to crop the captured image
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Image can not converted to CIImage")
            }

            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage){
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model failed.")
        }
        
        let request = VNCoreMLRequest(model: model) { req, err in
            guard let results = req.results as? [VNClassificationObservation] else { //this class holds classification observations after our models been processed.
                fatalError("Model failed to process image.")
            }
            print(results)
            if let highestConfidenceResult = results.first {
                if highestConfidenceResult.identifier.contains("hotdog"){
                    self.navigationItem.title = "Hotdog!"
                    self.predictionLabel.text = "Probability: \(String(highestConfidenceResult.confidence))"
                } else {
                    self.navigationItem.title = "Not Hotdog!"
                    self.predictionLabel.text = "It can be \(highestConfidenceResult.identifier) with \(String(highestConfidenceResult.confidence)) probability!"
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
        
    }
    

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
    }
    
}

