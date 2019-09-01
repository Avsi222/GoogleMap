//
//  MenuViewController.swift
//  MapProject
//
//  Created by Арсений Дорогин on 01/09/2019.
//  Copyright © 2019 Арсений Дорогин. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var openCameraButton:UIButton!
    @IBOutlet weak var openMapButton:UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initButton()
        
    }
    
    func initButton(){
        openMapButton.cornerButton()
        openCameraButton.cornerButton()
        openMapButton.addTarget(self, action: #selector(openMap), for: .touchUpInside)
        openCameraButton.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
    }
    
    @objc
    func openMap(_ sender: UIButton){
        performSegue(withIdentifier: "openMap", sender: self)
    }
    
    @objc
    func openCamera(_ sender: UIButton){
        // Проверка, поддерживает ли устройство библиотеку
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        // Создаём контроллер и настраиваем его
        let imagePickerController = UIImagePickerController()
        // Источник изображений: библиотека фото
        imagePickerController.sourceType = .photoLibrary
        // Изображение можно редактировать
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        // Показываем контроллер
        present(imagePickerController, animated: true)
    }

}

extension MenuViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Если нажали на кнопку Отмена, то UIImagePickerController надо закрыть
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Мы получили медиа от контроллера
        // Изображение надо достать из словаря info
        guard let image = extractImage(from: info) else { return  }
        let success = DataManager().saveImage(image: image, fileName: "myImage")
        // Закрываем UIImagePickerController
        picker.dismiss(animated: true)
        if success{
            alerts().showSuccesAlert(vc: self, title: "Отлично", message: "Изображений сохранено")
        }else{
            alerts().showErrorAlert(vc: self, message: "Изображение не сохранено")
        }
    }
    
    // Метод, извлекающий изображение
    private func extractImage(from info: [UIImagePickerController.InfoKey: Any]) -> UIImage? {
        // Пытаемся извлечь отредактированное изображение
        if let image = info[.editedImage] as? UIImage {
            return image
            // Пытаемся извлечь оригинальное
        } else if let image = info[.originalImage] as? UIImage {
            return image
        } else {
            // Если изображение не получено, возвращаем nil
            return nil
        }
    }

}
