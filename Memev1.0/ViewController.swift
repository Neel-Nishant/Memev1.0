//
//  ViewController.swift
//  Memev1.0
//
//  Created by Neel Nishant on 22/12/17.
//  Copyright © 2017 Neel Nishant. All rights reserved.
//

import UIKit

struct Meme {
    var topText: String
    var bottomText: String
    var originalImage: UIImage
    var memedImage: UIImage
    
}
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    let memeTextAttributes:[String:Any] = [
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
        NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedStringKey.strokeWidth.rawValue: -4.0]
    
    var memeImage: UIImage!
    var memes: [Meme]!
    
    
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var selectedImage: UIImageView!
    
    @IBOutlet weak var selectImageToolBar: UIToolbar!
    @IBOutlet weak var shareNavBar: UIToolbar!
    
    @IBOutlet weak var cancelBtn: UIBarButtonItem!
    @IBOutlet weak var shareBtn: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memes = [Meme]()
        
        setTextFields(textField: topTextField)
        setTextFields(textField: bottomTextField)
        
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        
        cancelBtn.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if selectedImage.image == nil {
            shareBtn.isEnabled = false
        }
        else {
            shareBtn.isEnabled = true
            cancelBtn.isEnabled = true
        }
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToNotification()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        unsubscribeFromNotification()
    }
    
    //MARK:- set TextField
    func setTextFields(textField: UITextField){
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        
    }
    
    //MARK:- textField Methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK:- Notification Methods
    
    func subscribeToNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromNotification() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    @objc func keyboardWillShow(notification: Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
         if bottomTextField.isFirstResponder {
//            view.frame.origin.y += getKeyboardHeight(notification)
            view.frame.origin.y = 0
        }
    }
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    //MARK:- Image picker method
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            selectedImage.image = image
            selectedImage.contentMode = .scaleAspectFit
        }
        print("Finished picking media")
        dismiss(animated: true, completion: nil)
    }
    
    //MARK:- creating and Saving memes
    
    func generateMeme() -> UIImage {
        
        shareNavBar.isHidden = true
        selectImageToolBar.isHidden = true
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let meme: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        shareNavBar.isHidden = false
        selectImageToolBar.isHidden = false
        return meme
    }
    
    func save() {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: selectedImage.image!, memedImage: memeImage)
        memes.append(meme)
    }
    //MARK:- IBActions
 
    
    @IBAction func pickImage(_ sender: UIBarButtonItem) {
        let imgPickerController = UIImagePickerController()
        
        if sender.tag == 0 {
            imgPickerController.sourceType = .camera
            
        }
        else if sender.tag == 1 {
            imgPickerController.sourceType = .photoLibrary
        }
        imgPickerController.delegate = self
        present(imgPickerController, animated: true, completion: nil)
    }

    
    @IBAction func shareMeme(_ sender: Any) {
        memeImage = generateMeme()
        let activityController = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
        present(activityController, animated: true) {
            self.save()
        }
        
    }
    @IBAction func cancelPressed(_ sender: Any) {
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        selectedImage.image = nil
    }
}

