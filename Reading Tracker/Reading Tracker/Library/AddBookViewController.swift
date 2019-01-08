//
//  AddBookViewController.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 15.10.2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

final class AddBookViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var onCompleted: ((BookModel) -> Void)?
    private var spinner: SpinnerView?
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
        
        let navBar = NavigationBar()
        navBar.configure(model: NavigationBarModel(title: "Новая книга",
                                                   onBackButtonPressed: ({ [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }), onFrontButtonPressed: ({ [weak self] in
            self?.spinner?.show()
            var type: BookType = .unknown
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
            
            if model.title.isEmpty {
                self?.spinner?.hide()
                let alert = UIAlertController(title: "Ошибка!", message: "Пустое название книги", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
                return
            }
            
            model.id = FirestoreManager.DBManager.addBook(book: model, completion: ({ bookId in
                FirebaseStorageManager.DBManager.uploadCover(cover: model.image ?? UIImage(named: "bookPlaceholder")!, bookId: bookId, completion: ({ [weak self] in
                    self?.spinner?.hide()
                    self?.onCompleted?(model)
                    self?.navigationController?.popViewController(animated: true)
                }), onError: ({ [weak self] in
                    self?.spinner?.hide()
                }))
            }))
        })))
        navBar.backgroundColor = UIColor(rgb: 0x2f5870)
        navBar.setBackButtonImage(image: UIImage(named: "back"))
        navBar.setFrontButtonImage(image: UIImage(named: "tick"))
        view.addSubview(navBar)
        navBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        self.navBar = navBar
        
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
        nameTextField.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        nameTextField.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        nameTextField.autoPinEdge(.top, to: .bottom, of: navBar, withOffset: SizeDependent.instance.convertPadding(48))
        
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
        authorTextField.autoPinEdge(.top, to: .bottom, of: lineView, withOffset: SizeDependent.instance.convertPadding(48))
        
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
        mediaDropdown.autoPinEdge(.top, to: .bottom, of: lineView2, withOffset: SizeDependent.instance.convertPadding(32))
        mediaDropdown.autoSetDimension(.height, toSize: 33)
        self.mediaDropdown = mediaDropdown
        
        let bookStub = AddBookView(frame: .zero)
        view.addSubview(bookStub)
        bookStub.autoAlignAxis(toSuperviewAxis: .vertical)
        bookStub.autoPinEdge(.top, to: .bottom, of: lineView2, withOffset: SizeDependent.instance.convertPadding(32 * 2) + 32 + 9)
        bookStub.autoSetDimensions(to: CGSize(width: 84, height: 101))
        bookStub.addTarget(self, action: #selector(onAddCover), for: .touchUpInside)
        self.bookStub = bookStub
        
        let addedBookStub = AddedBookView(frame: .zero, image: nil)
        view.addSubview(addedBookStub)
        addedBookStub.autoAlignAxis(toSuperviewAxis: .vertical)
        addedBookStub.autoPinEdge(.top, to: .bottom, of: lineView2, withOffset: SizeDependent.instance.convertPadding(32 * 2) + 32 + 9)
        addedBookStub.autoSetDimensions(to: CGSize(width: 155, height: 255))
        addedBookStub.addTarget(self, action: #selector(onAddCover), for: .touchUpInside)
        self.addedBookStub = addedBookStub
        
        updateCover(hasBook: false)
        setupSpinner()
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
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[.originalImage] as? UIImage
        updateCover(hasBook: true)
        addedBookStub?.imageStub?.image = image
    }
    
    private func setupSpinner() {
        let spinner = SpinnerView(frame: .zero)
        view.addSubview(spinner)
        
        view.bringSubviewToFront(spinner)
        spinner.autoPinEdgesToSuperviewEdges()
        self.spinner = spinner
    }

    private func alertError(reason: String) {
        let alert = UIAlertController(title: "Ошибка!", message: reason, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

