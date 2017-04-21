//
//  IRAddGameViewController.swift
//  iRullo
//
//  Created by formador on 7/4/17.
//  Copyright © 2017 formador. All rights reserved.
//

import UIKit
import CoreData

protocol IRAddGameViewControllerDelegate {
    func didAddGame()
}


class IRAddGameViewController: UIViewController {
    
    //MARK: - Variables locales
    var manageContext : NSManagedObjectContext?
    var game : Game?
    var datePicker : UIDatePicker!
    var dateFormatter = DateFormatter()
    var irDelegate : IRAddGameViewControllerDelegate?
    
    //MARK: - IBOutlets
    @IBOutlet weak var myImagenGame: UIImageView!
    @IBOutlet weak var mySwitch: UISwitch!
    @IBOutlet weak var myTitleGame: UITextField!
    @IBOutlet weak var myBorrowedToGame: UITextField!
    @IBOutlet weak var myBorrowedDateGame: UITextField!
    @IBOutlet weak var myEliminarBTN: UIButton!
    
    //MARK: - IBActions
    @IBAction func myDeleteGameFromCoreData(_ sender: Any) {
        if let context = manageContext{
            context.delete(game!)
            game = nil
            irDelegate?.didAddGame()
            _ = navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBAction func mySwitchChangeValue(_ sender: UISwitch) {
        if sender.isOn{
            myBorrowedToGame.isEnabled = true
            myBorrowedDateGame.isEnabled = true
            myBorrowedDateGame.text = dateFormatter.string(from: Date())
        }else{
            myBorrowedToGame.isEnabled = false
             myBorrowedToGame.text = ""
            myBorrowedDateGame.isEnabled = false
            myBorrowedDateGame.text = ""
        }
        
        
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        //image
        myImagenGame.isUserInteractionEnabled = true
        let tapGR = UITapGestureRecognizer(target: self,
                                           action: #selector(pickerPhoto))
        myImagenGame.addGestureRecognizer(tapGR)
        
        //Teclado
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: Notification.Name.UIKeyboardWillShow,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: Notification.Name.UIKeyboardWillHide,
                                               object: nil)
        
        //datePicker
        datePicker = UIDatePicker(frame: CGRect(x: 0, y: 210, width: 320, height: 216))
        datePicker.datePickerMode = .date
        datePicker.addTarget(self,
                             action: #selector(datePickerChange(_:)),
                             for: .valueChanged)
        myBorrowedDateGame.inputView = datePicker
        
        //Dos logicas ara el mismo VC / añadir / editar
        if game == nil{
            self.title = "Añadir videojuego"
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                                    target: self,
                                                                    action: #selector(cancelButtonPressed))
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                                     target: self,
                                                                     action: #selector(saveButtonPressed))
            myEliminarBTN.isHidden = true
            mySwitch.isOn = false
        }else{
            self.title = "Editar Videojuego"
            myTitleGame.text = game?.title
            
            if let borrowed = game?.borrowed{
                mySwitch.isOn = borrowed
            }
            
            myBorrowedToGame.text = game?.borrowedTo
            
            if let borrowedDate = game?.borrowedDate as Date?{
                myBorrowedDateGame.text = dateFormatter.string(from: borrowedDate)
            }
            
            if let imageData = game?.image as Data?{
                myImagenGame.image = UIImage(data: imageData)
            }
            myEliminarBTN.isHidden = false
        }
        
        if !mySwitch.isOn{
            myBorrowedToGame.isEnabled = false
            myBorrowedDateGame.isEnabled = false
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       super.viewWillDisappear(animated)
        if game != nil{
            saveGame()
        }
    }
    
    
    //MARK: -  UTILS
    func keyboardWillShow(_ notification : Notification){
        let info = notification.userInfo!
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardTime = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        UIView.animate(withDuration: keyboardTime) {
            self.view.frame.origin.y = -(keyboardFrame.height)
        }
    }
    
    func keyboardWillHide(_ notification : Notification){
        let info = notification.userInfo!
        let keyboardTime = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        UIView.animate(withDuration: keyboardTime) {
            self.view.frame.origin.y = 0
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func datePickerChange(_ picker : UIDatePicker){
        myBorrowedDateGame.text = dateFormatter.string(from: picker.date)
    }
    
    func cancelButtonPressed(){
        dismiss(animated: true, completion: nil)
    }
    
    func saveButtonPressed(){
        saveGame()
        dismiss(animated: true, completion: nil)
    }
    
    func saveGame(){
        //inyectamos el contexto
        if let context = manageContext{
            
            var editedGame : Game?
            
            if game == nil{
                editedGame = Game(context: context)
                editedGame?.dateCreated = NSDate()
            }else{
                editedGame = game
            }
            
            if let editedGameDes = editedGame{
                
                editedGameDes.title = self.myTitleGame.text
                editedGameDes.borrowed = self.mySwitch.isOn
                if let imageData = myImagenGame.image{
                    editedGameDes.image = UIImageJPEGRepresentation(imageData, 0.5) as NSData?
                }
                if editedGameDes.borrowed{
                    editedGameDes.borrowedTo = self.myBorrowedToGame.text?.uppercased()
                    editedGameDes.borrowedDate = dateFormatter.date(from: myBorrowedDateGame.text!) as NSDate?
                }else{
                    editedGameDes.borrowedTo = nil
                    editedGameDes.borrowedDate = nil
                }
                
                do{
                    try context.save()
                    irDelegate?.didAddGame()
                }catch let error{
                    print("Error: \(error.localizedDescription) \n error al guardar los datos")
                }
            }
        }
    }

    

}//TODO: - Fin e la clase

extension IRAddGameViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func pickerPhoto(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            muestraMenu()
        }else{
            muestraLibreriaFotos()
        }
    }
    
    func muestraMenu(){
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        let tomaFotoCamarAction = UIAlertAction(title: "Toma foto", style: .default) { _ in
            self.muestraCamaraDisposito()
        }
        let seleccionaFotoAction = UIAlertAction(title: "Selecciona desde la Librería", style: .default) { _ in
            self.muestraLibreriaFotos()
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(tomaFotoCamarAction)
        alertVC.addAction(seleccionaFotoAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    func muestraLibreriaFotos(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func muestraCamaraDisposito(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let imageData = info[UIImagePickerControllerOriginalImage] as? UIImage{
            myImagenGame.image = imageData
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
