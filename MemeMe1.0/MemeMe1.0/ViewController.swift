//
//  ViewController.swift
//  MemeMe1.0
//
//  Created by George on 04/07/2020.
//  Copyright © 2020 Master. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
        
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var resetButton: UIBarButtonItem!
    
    var currentSelectedTextField: UITextField? = nil
    var memedImage: UIImage! = nil
    
    struct Meme {
        let topText:String
        let bottomText:String
        let originalImage:UIImage
        let memedImage:UIImage
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.image = image
            shareButton.isEnabled = true
        }
            dismiss(animated: true, completion: nil)
    }
        
    func imagePickerControllerDidCancel(_: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        shareButton.isEnabled = false
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentSelectedTextField = textField
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        switch textField.tag {
        case 0:
            let text = textField.text
            if text?.count == 0 {
                textField.text = "TOP"
            }
        case 1:
             if textField.text?.count == 0 {
                textField.text = "BOTTOM"
            }
       
        default:
           return
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMemeTextField(textField: topTextField, text: "TOP")
        configureMemeTextField(textField: bottomTextField, text: "BOTTOM")
        imagePickerView.contentMode = .scaleAspectFit
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    
    func configureMemeTextField(textField: UITextField, text:String){
        textField.text = text
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
    }
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: -4.5
        ]
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
        name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isEditing, view.frame.origin.y == 0 {self.view.frame.origin.y -= getKeyboardHeight(notification)}
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
            if bottomTextField .isEditing, view.frame.origin.y != 0{self.view.frame.origin.y += getKeyboardHeight(notification)}
    }
    
    
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    
    

    @IBAction func pickAnImageFromAlbum(_ sender: Any!) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
        
        }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func handleResetClick(_ sender: Any) {
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        imagePickerView.image = nil
        memedImage = nil
        shareButton.isEnabled = false
    }
    
    func generateMemedImage() -> UIImage {

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return memedImage
    }
    
    @IBAction func handleShareClick(_ sender: Any) {
        memedImage = generateMemedImage()
        let vc = UIActivityViewController(activityItems: [memedImage!], applicationActivities: nil)
        vc.popoverPresentationController?.sourceView = self.view
        vc.completionWithItemsHandler = {
            (activity, success, items, error) in
            if success {
                self.saveMeme()
            }
        }
        present(vc, animated: true, completion: nil)
        
    }
    
    func saveMeme() {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
        print(meme)
    }
    
}
