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
    //selectの方がいいかも
    var commonButton: UIButton!
    
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
    //Arrayではないので名前を修正する。
    //Todo猪股
    var todoInfo = TodoInfo() {
        didSet {
            switch todoInfo.todoViewType {
            case 0:
                todoViewType = .normal
            case 1:
                todoViewType = .just
            case 2:
                todoViewType = .remember
            case 3:
                todoViewType = .either
            case 4:
                todoViewType = .toBuy
            default:
                todoViewType = .normal
            }
        }
    }
    var lightBlue: UIColor { return UIColor.init(red: 186 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1.0) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePickerView()
        timePickerView()
        titleTextField.text = todoInfo.todoTitle
        dateTextField.text = todoInfo.todoScheduleDate
        timeTextField.text = todoInfo.todoScheduleTime
        createdLabel.text = "createdAt:  " + (todoInfo.todoCreated ?? "yyyy/MM/dd")
        updatedLabel.text = "updatedAt: " + (todoInfo.todoUpdated ?? "yyyy/MM/dd")
        detailTextView.text = todoInfo.todoDetail
        paintButton()
        setupLabel()
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
                Firestore.firestore().collection("users/\(user.uid)/todos").document(todoInfo.todoId!).updateData(
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
            Firestore.firestore().collection("users/\(user.uid)/todos").document(todoInfo.todoId!).updateData(
                [
                    "isDone": !todoInfo.todoIsDone!,
                    "viewType": todoViewType.rawValue,
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
            Firestore.firestore().collection("users/\(user.uid)/todos").document(todoInfo.todoId!).delete() { error in
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
    

    @IBAction func tapCommonButton(_ sender: Any) {
        let tag = (sender as AnyObject).tag
        guard let tag = tag else {
            print("タグが設定されていません")
            return
        }
        switch tag {
        case 1:
            todoViewType = .just
            commonButton = categoryJustButton
        case 2:
            todoViewType = .remember
            commonButton = categoryRememberButton
        case 3:
            todoViewType = .either
            commonButton = categoryEitherButton
        case 4:
            todoViewType = .toBuy
            commonButton = categoryToBuyButton
        default:
            break
        }
        clearButton()
        commonButton.configuration?.background.backgroundColor = lightBlue
        commonButton.tintColor = UIColor.white
        commonButton.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 13, weight: .bold)
            return outgoing
        }
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
    func setupLabel() {
        switch todoInfo.todoIsDone {
        case true:
            isDoneLabel.text = "完了"
            doneButton.setTitle("未完了にする", for: .normal)
        case false:
            isDoneLabel.text = "未完了"
            doneButton.setTitle("完了済みにする", for: .normal)
        default:
            print("エラー")
        }
    }
    func clearButton() {
        let buttons: [UIButton] = [categoryJustButton, categoryRememberButton, categoryEitherButton, categoryToBuyButton]
        //シーケンス必要だったので
        let buttonsCount = AnySequence { () -> AnyIterator<Int> in
            var count = 0
            return AnyIterator {
                defer { count += 1 }
                return count < buttons.count ? count : nil
            }
        }
        for i in buttonsCount {
            buttons[i].configuration?.background.backgroundColor = UIColor.white
            buttons[i].tintColor = .none
            buttons[i].configuration?.titleTextAttributesTransformer = .none
        }
    }
    func paintButton() {
        if todoViewType != .normal {
            switch todoViewType {
            case .just:
                commonButton = categoryJustButton
            case .remember:
                commonButton = categoryRememberButton
            case .either:
                commonButton = categoryEitherButton
            case .toBuy:
                commonButton = categoryToBuyButton
            default:
                break
            }
            commonButton.configuration?.background.backgroundColor = lightBlue
            commonButton.tintColor = UIColor.white
            commonButton.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = UIFont.systemFont(ofSize: 13, weight: .bold)
                return outgoing
            }
        }
    }
    func datePickerView() {
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy/MM/dd"
        date = todoInfo.todoScheduleDate ?? "yyyy/MM/dd"
        dateTextField.text = todoInfo.todoScheduleDate
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
        time = todoInfo.todoScheduleTime ?? "HH:mm"
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
