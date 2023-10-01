//
//  TodoEditViewController.swift
//  Todo
//
//  Created by ryo.inomata on 2023/07/13.
//

// SplashViewControllerが使えてないので、最初のログイン確認処理の為に使うようにする。
// エディタ画面のタイトルの下に何月何日何時を表示する。
// ライフサイクルの理解が出来ていない為調べる。モーダルとライフサイクルの関係について調べる。

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore


class TodoEditViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var updatedLabel: UILabel!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var isDoneLabel: UILabel!
    @IBOutlet weak var categoryJustButton: UIButton!
    @IBOutlet weak var categoryRememberButton: UIButton!
    @IBOutlet weak var categoryEitherButton: UIButton!
    @IBOutlet weak var categoryToBuyButton: UIButton!
    
    enum CategoryType: Int {
        case normal     = 0
        case just       = 1
        case remember   = 2
        case either     = 3
        case toBuy      = 4
    }
    var todoViewType = CategoryType.normal
    
    var datePicker: UIDatePicker = UIDatePicker()
    var timePicker: UIDatePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    var date = ""
    var time = ""
    
    var categoryJust: Bool?
    var categoryRemember: Bool?
    var categoryEither: Bool?
    var categoryToBuy: Bool?
    
    //① 一覧画面から受け取るように変数を用意
    var todoId: String!
    var todoTitle: String!
    var todoCreated: String!
    var todoUpdated: String!
    var todoDetail: String!
    var todoIsDone: Bool!
    var todoScheduleDate: String!
    var todoScheduleTime: String!
    
    // Firestoreから取得するTodoのid,title,detail,idDoneを入れる配列を用意
    var todoIdArray: [String] = []
    var todoTitleArray: [String] = []
    var todoCreatedArray: [String] = []
    var todoDetailArray: [String] = []
    var todoIsDoneArray: [Bool] = []
    private var todoArray: [TodoInfo] = [TodoInfo]()
    var lightBlue: UIColor { return UIColor.init(red: 186 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1.0) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePickerView()
        timePickerView()
        // ②初期値をセット
        titleTextField.text = todoTitle
        dateTextField.text = todoScheduleDate
        timeTextField.text = todoScheduleTime
        createdLabel.text = "createdAt:  " + todoCreated
        updatedLabel.text = "updatedAt: " + todoUpdated
        detailTextView.text = todoDetail
        paintButton()
        switch todoIsDone {
        case true:
            isDoneLabel.text = "完了"
            doneButton.setTitle("未完了にする", for: .normal)
        case false:
            isDoneLabel.text = "未完了"
            doneButton.setTitle("完了済みにする", for: .normal)
        default:
            print("エラー")
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        // レイアウトを設定
        detailTextView.layer.borderWidth = 1.0
        detailTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.9).cgColor
        detailTextView.layer.cornerRadius = 5.0
        detailTextView.layer.masksToBounds = true
    }

    // ④編集ボタンの実装
    
    @IBAction func tapEditButton(_ sender: Any) {
        if let title = titleTextField.text,
           let detail = detailTextView.text {
            if let user = Auth.auth().currentUser {
                Firestore.firestore().collection("users/\(user.uid)/todos").document(todoId).updateData(
                [
                    "title": title,
                    "detail": detail,
                    "updatedAt": FieldValue.serverTimestamp(),
                    "scheduleDate": date,
                    "scheduleTime": time,
                    "viewType": todoViewType.rawValue,
                ]
                , completion: { error in
                    if let error = error {
                        print("TODO更新失敗: " + error.localizedDescription)
                        let dialog = UIAlertController(title: "TODO更新失敗", message: error.localizedDescription, preferredStyle: .alert)
                        dialog.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(dialog, animated: true, completion: nil)
                    } else {
                        print("TODO更新成功")
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    @IBAction func tapCloseButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // ③完了、未完了切り替えボタンの実装
    @IBAction func tapDoneButton(_ sender: Any) {
        if let user = Auth.auth().currentUser {
            Firestore.firestore().collection("users/\(user.uid)/todos").document(todoId).updateData(
                [
                    "isDone": !todoIsDone,
                    "updatedAt": FieldValue.serverTimestamp()
                ]
                , completion: {error in
                    if let error = error {
                        print("TODO更新失敗: " + error.localizedDescription)
                        let dialog = UIAlertController(title: "TODO更新失敗", message: error.localizedDescription, preferredStyle: .alert)
                        dialog.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(dialog, animated:  true, completion: nil)
                    } else {
                        print("TODO更新成功")
                        self.dismiss(animated: true, completion: nil)
                    }
                })
        }
    }
    
    @IBAction func tapDeleteButton(_ sender: Any) {
        if let user = Auth.auth().currentUser {
            Firestore.firestore().collection("users/\(user.uid)/todos").document(todoId).delete() { error in
                if let error = error {
                    print("TODO削除失敗: " + error.localizedDescription)
                    let dialog = UIAlertController(title: "TODO削除失敗", message: error.localizedDescription, preferredStyle: .alert)
                    dialog.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(dialog, animated: true, completion: nil)
                } else {
                    print("TODO削除成功")
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
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
        //dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        dateFormatter.dateFormat = "yyyy/MM/dd"
        date = dateFormatter.string(from: Date())
        dateTextField.text = date
        //datePicker.datePickerMode = UIDatePicker.Mode.dateAndTime
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
