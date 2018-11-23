//
//  AddBookViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 15.10.2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit
import ActionSheetPicker_3_0
import BarcodeScanner

final class AddBookViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var onCompleted: ((BookModel) -> Void)?
    private var spinner: UIActivityIndicatorView?
    private var navBar: NavigationBar?
    private var bookStub: AddBookView?
    private var addedBookStub: AddedBookView?
    private var nameTextField: RTTextField?
    private var authorTextField: RTTextField?
    private var nameTextFieldDelegate = IntermediateTextFieldDelegate()
    private var authorTextFieldDelegate = FinishTextFieldDelegate()
    private var mediaDropdown: DropdownMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupSpinner()
        
        let placeholderTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 20.0)!]
            as [NSAttributedString.Key : Any]
        
        let nameTextField = RTTextField(padding: .zero)
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Название книги", attributes: placeholderTextAttributes)
        nameTextField.backgroundColor = .clear
        nameTextField.autocorrectionType = .no
        nameTextField.returnKeyType = .continue
        nameTextField.delegate = nameTextFieldDelegate
        self.nameTextField = nameTextField
        
        view.addSubview(nameTextField)
        nameTextField.autoAlignAxis(toSuperviewAxis: .vertical)
        nameTextField.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 124, left: 16, bottom: 0, right: 16), excludingEdge: .bottom)
        
        let lineView = UIView(frame: .zero)
        lineView.backgroundColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.5)
        
        view.addSubview(lineView)
        lineView.autoPinEdge(.top, to: .bottom, of: nameTextField, withOffset: 8)
        lineView.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        lineView.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        lineView.autoSetDimension(.height, toSize: 1)
        
        let authorTextField = RTTextField(padding: .zero)
        authorTextField.attributedPlaceholder = NSAttributedString(string: "Автор", attributes: placeholderTextAttributes)
        authorTextField.backgroundColor = .clear
        authorTextField.autocorrectionType = .no
        authorTextField.returnKeyType = .done
        authorTextField.delegate = authorTextFieldDelegate
        nameTextFieldDelegate.nextField = authorTextField
        self.authorTextField = authorTextField
        
        view.addSubview(authorTextField)
        authorTextField.autoAlignAxis(toSuperviewAxis: .vertical)
        authorTextField.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        authorTextField.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        authorTextField.autoPinEdge(.top, to: .bottom, of: lineView, withOffset: 59)
        
        let lineView2 = UIView(frame: .zero)
        lineView2.backgroundColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.5)
        
        view.addSubview(lineView2)
        lineView2.autoPinEdge(.top, to: .bottom, of: authorTextField, withOffset: 8)
        lineView2.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        lineView2.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        lineView2.autoSetDimension(.height, toSize: 1)
        
        let bookTypes =  ["Бумажная книга", "Элекронная книга", "Смартфон", "Планшет"]
        let mediaDropdown = DropdownMenu(frame: .zero, optionsList: bookTypes)
        view.addSubview(mediaDropdown)
        mediaDropdown.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        mediaDropdown.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        mediaDropdown.autoPinEdge(.top, to: .bottom, of: lineView2, withOffset: 59)
        mediaDropdown.autoSetDimension(.height, toSize: 33)
        self.mediaDropdown = mediaDropdown
        
        let bookStub = AddBookView(frame: .zero)
        view.addSubview(bookStub)
        bookStub.autoAlignAxis(toSuperviewAxis: .vertical)
        bookStub.autoPinEdge(.top, to: .bottom, of: lineView2, withOffset: 59 + 32 + 9 + 58)
        bookStub.autoSetDimensions(to: CGSize(width: 84, height: 101))
        bookStub.addTarget(self, action: #selector(onAddCover), for: .touchUpInside)
        self.bookStub = bookStub
        
        let addedBookStub = AddedBookView(frame: .zero, image: nil)
        view.addSubview(addedBookStub)
        addedBookStub.autoAlignAxis(toSuperviewAxis: .vertical)
        addedBookStub.autoPinEdge(.top, to: .bottom, of: lineView2, withOffset: 59 + 32 + 9 + 32)
        addedBookStub.autoSetDimensions(to: CGSize(width: 155, height: 255))
        addedBookStub.addTarget(self, action: #selector(onAddCover), for: .touchUpInside)
        self.addedBookStub = addedBookStub
        
        updateCover(hasBook: false)
    }
    
    private func updateCover(hasBook: Bool) {
        bookStub?.isHidden = hasBook
        addedBookStub?.isHidden = !hasBook
    }
    
    @objc private func onAddCover() {
        let alert = UIAlertController(title: "Добавить фото обложки книги?", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Галерея", style: .default, handler: ({ [weak self] _ in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum;
            imagePicker.allowsEditing = false
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.present(imagePicker, animated: true, completion: nil)
            }
        })))
        
        alert.addAction(UIAlertAction(title: "Камера", style: .default, handler: ({ [weak self] _ in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.present(imagePicker, animated: true, completion: nil)
            }
        })))
        alert.addAction(UIAlertAction(title: "Сканировать ICBN", style: .default, handler: ({ [weak self] _ in
            /*let vc = BarcodeScannerViewController()
            vc.codeDelegate = self
            vc.errorDelegate = self
            vc.dismissalDelegate = self
            
            strongSelf.present(viewController, animated: true, completion: nil)*/
        })))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[.originalImage] as? UIImage
        updateCover(hasBook: true)
        addedBookStub?.imageStub?.image = image
    }
    
    private func setupNavigationBar() {
        let navBar = NavigationBar()
        navBar.configure(model: NavigationBarModel(title: "Новая книга", backButtonText: "Назад", frontButtonText: "Готово", onBackButtonPressed: ({ [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }), onFrontButtonPressed: ({ [weak self] in
            var type: BookType = .paper
            if let index = self?.mediaDropdown?.selectedIndex {
                switch index {
                case 0:
                    type = .paper
                case 1:
                    type = .ebook
                case 2:
                    type = .smartphone
                case 3:
                    type = .tab
                default:
                    break
                }
            }
            var model = BookModel(title: self?.nameTextField?.text ?? "",
                                  author: self?.authorTextField?.text ?? "",
                                  image: self?.addedBookStub?.imageStub?.image,
                                  lastUpdated: Date(),
                                  type: type)
            
            model.id = FirestoreManager.DBManager.addBook(book: model, completion: ({ bookId in
                FirebaseStorageManager.DBManager.uploadCover(cover: model.image, bookId: bookId, completion: ({ [weak self] in
                    self?.onCompleted?(model)
                    self?.navigationController?.popViewController(animated: true)
                }))
            }))
        })))
        navBar.backgroundColor = UIColor(rgb: 0x2f5870)
        view.addSubview(navBar)
        navBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        self.navBar = navBar
    }
    
    private func setupSpinner() {
        let spinner = UIActivityIndicatorView()
        view.addSubview(spinner)
        
        view.bringSubviewToFront(spinner)
        spinner.autoCenterInSuperview()
        spinner.backgroundColor = UIColor(rgb: 0x555555).withAlphaComponent(0.7)
        spinner.layer.cornerRadius = 8
        spinner.autoSetDimensions(to: CGSize(width: 64, height: 64))
        self.spinner = spinner
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    private class DropdownMenu: UIView {
        var selectedIndex: Int = 0
        private var optionsList: [String]
        
        init(frame: CGRect, optionsList: [String]) {
            self.optionsList = optionsList
            super.init(frame: frame)
            
            setupSubviews()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupSubviews() {
            let mainTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 20.0)!]
                as [NSAttributedString.Key : Any]
            
            let mainButton = UIButton(forAutoLayout: ())
            mainButton.setAttributedTitle(NSAttributedString(string: "Медиа", attributes: mainTextAttributes), for: [])
            mainButton.contentHorizontalAlignment = .left
            addSubview(mainButton)
            mainButton.autoSetDimension(.height, toSize: 32)
            mainButton.autoPinEdgesToSuperviewEdges(with: .zero)
            
            mainButton.addTarget(self, action: #selector(mainButtonTap(_:)), for: .touchUpInside)
            
            let arrowImageView = UIImageView(image: UIImage(named: "down"))
            mainButton.addSubview(arrowImageView)
            arrowImageView.autoSetDimensions(to: CGSize(width: 10, height: 5))
            arrowImageView.autoAlignAxis(toSuperviewAxis: .horizontal)
            arrowImageView.autoPinEdge(toSuperviewEdge: .right)
            
            let mainButtonLine = UIView(forAutoLayout: ())
            mainButtonLine.backgroundColor = UIColor(rgb: 0x2f5870).withAlphaComponent(0.5)
            addSubview(mainButtonLine)
            mainButtonLine.autoSetDimension(.height, toSize: 1)
            mainButtonLine.autoPinEdge(toSuperviewEdge: .left)
            mainButtonLine.autoPinEdge(toSuperviewEdge: .right)
            mainButtonLine.autoPinEdge(.top, to: .bottom, of: mainButton, withOffset: 8)
        }
        
        @objc private func mainButtonTap(_ sender: UIButton) {
            let picker = ActionSheetMultipleStringPicker(title: "Медиа", rows: [
                optionsList
                ], initialSelection: [selectedIndex], doneBlock: { [weak self]
                    picker, values, indexes in
                    let textAttributes = [
                        NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
                        NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 20.0)!]
                        as [NSAttributedString.Key : Any]
                    if let values = values,
                       let optionIndex = values.first as? Int,
                       let text = self?.optionsList[optionIndex] {
                        self?.selectedIndex = optionIndex
                        sender.setAttributedTitle(NSAttributedString(string: text, attributes: textAttributes), for: [])
                    }
                    
                    return
            }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
            
            picker?.setTextColor(UIColor(rgb: 0x2f5870))
            
            let textAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 17.0)!]
                as [NSAttributedString.Key : Any]
            
            let finishButton = UIButton(forAutoLayout: ())
            finishButton.setAttributedTitle(NSAttributedString(string: "Готово", attributes: textAttributes), for: [])
            picker?.setDoneButton(UIBarButtonItem(customView: finishButton))
            
            let closeButton = UIButton(forAutoLayout: ())
            closeButton.setAttributedTitle(NSAttributedString(string: "Закрыть", attributes: textAttributes), for: [])
            picker?.setCancelButton(UIBarButtonItem(customView: closeButton))
            picker?.show()
        }
    }
    
    private class AddBookView: UIButton {
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            let titleView = UILabel(forAutoLayout: ())
            let textAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 20.0)!]
                as [NSAttributedString.Key : Any]
            titleView.numberOfLines = 0
            titleView.textAlignment = .center
            titleView.attributedText = NSAttributedString(string: "Обложка", attributes: textAttributes)
            
            addSubview(titleView)
            
            titleView.autoAlignAxis(toSuperviewAxis: .vertical)
            titleView.autoPinEdge(toSuperviewEdge: .top)
            
            let imageStub = UIImageView(image: UIImage(named: "addBookStub"))
            
            addSubview(imageStub)
            
            imageStub.autoAlignAxis(toSuperviewAxis: .vertical)
            imageStub.autoPinEdge(.top, to: .bottom, of: titleView, withOffset: 4)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    private class AddedBookView: UIButton {
        var imageStub: UIImageView?
        
        init(frame: CGRect, image: UIImage?) {
            super.init(frame: frame)
            
            let titleView = UILabel(forAutoLayout: ())
            let textAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
                NSAttributedString.Key.font : UIFont(name: "Avenir-Light", size: 14.0)!]
                as [NSAttributedString.Key : Any]
            titleView.numberOfLines = 0
            titleView.textAlignment = .center
            titleView.attributedText = NSAttributedString(string: "Обложка", attributes: textAttributes)
            
            addSubview(titleView)
            
            titleView.autoAlignAxis(toSuperviewAxis: .vertical)
            titleView.autoPinEdge(toSuperviewEdge: .top)
            
            let imageStub = UIImageView(image: image)
            imageStub.contentMode = .scaleAspectFit
            addSubview(imageStub)
            
            imageStub.autoAlignAxis(toSuperviewAxis: .vertical)
            imageStub.autoPinEdge(.top, to: .bottom, of: titleView, withOffset: 4)
            imageStub.autoSetDimensions(to: CGSize(width: 155, height: 222))
            self.imageStub = imageStub
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    private class IntermediateTextFieldDelegate: NSObject, UITextFieldDelegate {
        var nextField: UITextField?
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            nextField?.becomeFirstResponder()
            return true
        }
    }
    
    private class FinishTextFieldDelegate: NSObject, UITextFieldDelegate {
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            //TODO: check corectness
        }
    }
}
