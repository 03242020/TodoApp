//
//  TodoAddViewController.swift
//  Todo
//
//  Created by ryo.inomata on 2023/07/13.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class TodoAddViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    
    @IBOutlet weak var categoryJustButton: UIButton!
    @IBOutlet weak var categoryRememberButton: UIButton!
    @IBOutlet weak var categoryEitherButton: UIButton!
    @IBOutlet weak var categoryToBuyButton: UIButton!
    
    var lightBlue: UIColor { return UIColor.init(red: 186 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1.0) }
    var datePicker: UIDatePicker = UIDatePicker()
    var timePicker: UIDatePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    var date = ""
    var time = ""
    enum CategoryType: Int {
        case normal     = 0
        case just       = 1
        case remember   = 2
        case either     = 3
        case toBuy      = 4
    }
    var todoViewType = CategoryType.normal
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        datePickerView()
        timePickerView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidLayoutSubviews() {
        detailTextView.layer.borderWidth = 1.0
        detailTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        detailTextView.layer.cornerRadius = 5.0
        detailTextView.layer.masksToBounds = true
    }
    //ピッカービュー表示時に、年の部分も
    @IBAction func tapAddButton(_ sender: Any) {
        if let title = titleTextField.text,
            let detail = detailTextView.text {
            // ②ログイン済みか確認
            if let user = Auth.auth().currentUser {
                // ③FirestoreにTodoデータを作成する
        let createdTime = FieldValue.serverTimestamp()
                Firestore.firestore().collection("users/\(user.uid)/todos").document().setData(
                    [
                     "title": title,
                     "detail": detail,
                     "isDone": false,
                     "createdAt": createdTime,
                     "updatedAt": createdTime,
                     "scheduleDate": self.date,
                     "scheduleTime": self.time,
                     "viewType": todoViewType.rawValue
                    ],merge: true
                    ,completion: { error in
                        if let error = error {
                            // ③が失敗した場合
                            print("TODO作成失敗: " + error.localizedDescription)
                            let dialog = UIAlertController(title: "TODO作成失敗", message: error.localizedDescription, preferredStyle: .alert)
                            dialog.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(dialog, animated: true, completion: nil)
                        } else {
                            print("TODO作成成功")
                            // ④Todo一覧画面に戻る
                            self.dismiss(animated: true, completion: nil)
                        }
                })
            }
        }
    }

    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapCategoryJustButton(_ sender: Any) {
        print("categoryJustButton clicked")
            todoViewType = .just
            paintButton()
    }
    
    @IBAction func tapCategoryRememberButton(_ sender: Any) {
        print("categoryRememberButton clicked")
        todoViewType = .remember
        paintButton()
    }
    
    @IBAction func tapCategoryEitherButton(_ sender: Any) {
        print("categoryEitherButton clicked")
        todoViewType = .either
        paintButton()
    }
    
    @IBAction func tapCategoryToBuyButton(_ sender: Any) {
        print("categoryToBuyButton clicked")
        todoViewType = .toBuy
        paintButton()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    @objc func dateDone() {
        dateTextField.endEditing(true)
        date = dateFormatter.string(from: datePicker.date)
        dateTextField.text = date
    }
    @objc func timeDone() {
        timeTextField.endEditing(true)
        time = timeFormatter.string(from: timePicker.date)
        timeTextField.text = time
    }
    func paintButton() {
        categoryJustButton.configuration?.background.backgroundColor = UIColor.white
        categoryJustButton.tintColor = .none
        categoryJustButton.configuration?.titleTextAttributesTransformer = .none
        
        categoryRememberButton.configuration?.background.backgroundColor = UIColor.white
        categoryRememberButton.tintColor = .none
        categoryRememberButton.configuration?.titleTextAttributesTransformer = .none
        
        categoryEitherButton.configuration?.background.backgroundColor = UIColor.white
        categoryEitherButton.tintColor = .none
        categoryEitherButton.configuration?.titleTextAttributesTransformer = .none
        
        categoryToBuyButton.configuration?.background.backgroundColor = UIColor.white
        categoryToBuyButton.tintColor = .none
        categoryToBuyButton.configuration?.titleTextAttributesTransformer = .none
        
        if todoViewType == .just {
            categoryJustButton.configuration?.background.backgroundColor = lightBlue
            categoryJustButton.tintColor = UIColor.white
            categoryJustButton.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = UIFont.systemFont(ofSize: 13, weight: .bold)
                return outgoing
            }
        }
        if todoViewType == .remember {
            categoryRememberButton.configuration?.background.backgroundColor = lightBlue
            categoryRememberButton.tintColor = UIColor.white
            categoryRememberButton.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = UIFont.systemFont(ofSize: 13, weight: .bold)
                return outgoing
            }
        }
        if todoViewType == .either {
            categoryEitherButton.configuration?.background.backgroundColor = lightBlue
            categoryEitherButton.tintColor = UIColor.white
            categoryEitherButton.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = UIFont.systemFont(ofSize: 13, weight: .bold)
                return outgoing
            }
        }
        if todoViewType == .toBuy {
            categoryToBuyButton.configuration?.background.backgroundColor = lightBlue
            categoryToBuyButton.tintColor = UIColor.white
            categoryToBuyButton.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = UIFont.systemFont(ofSize: 13, weight: .bold)
                return outgoing
            }
        }
        print(type(of: todoViewType))
    }
    func datePickerView() {
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy/MM/dd"
        date = dateFormatter.string(from: Date())
        dateTextField.text = date
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.timeZone = NSTimeZone.local
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ja_JP")
        dateTextField.inputView = datePicker
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dateDone))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        // インプットビュー設定(紐づいているUITextfieldへ代入)
        dateTextField.inputView = datePicker
        dateTextField.inputAccessoryView = toolbar
    }
    func timePickerView() {
        timeFormatter.locale = Locale(identifier: "ja_JP")
        timeFormatter.dateFormat = "HH:mm"
        time = timeFormatter.string(from: Date())
        timeTextField.text = time
        timePicker.datePickerMode = UIDatePicker.Mode.time
        timePicker.timeZone = NSTimeZone.local
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.locale = Locale(identifier: "ja_JP")
        timeTextField.inputView = timePicker
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(timeDone))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        // インプットビュー設定(紐づいているUITextfieldへ代入)
        timeTextField.inputView = timePicker
        timeTextField.inputAccessoryView = toolbar
    }
}
