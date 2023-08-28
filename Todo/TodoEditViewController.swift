//
//  TodoEditViewController.swift
//  Todo
//
//  Created by ryo.inomata on 2023/07/13.
//

import UIKit
import Firebase

protocol KeyWordInputDelegate: AnyObject {
    func delegateBool(keyWord: Bool)
}

class TodoEditViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var isDoneLabel: UILabel!
    

    weak var delegate: KeyWordInputDelegate?
    //① 一覧画面から受け取るように変数を用意
    var todoId: String!
    var todoTitle: String!
    var todoDetail: String!
    var todoIsDone: Bool!
    
    // Firestoreから取得するTodoのid,title,detail,idDoneを入れる配列を用意
    var todoIdArray: [String] = []
    var todoTitleArray: [String] = []
    var todoDetailArray: [String] = []
    var todoIsDoneArray: [Bool] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ②初期値をセット
        titleTextField.text = todoTitle
        detailTextView.text = todoDetail
        
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
                    "updatedAt": FieldValue.serverTimestamp()
                ]
                , completion: { error in
                    if let error = error {
                        print("TODO更新失敗: " + error.localizedDescription)
                        let dialog = UIAlertController(title: "TODO更新失敗", message: error.localizedDescription, preferredStyle: .alert)
                        dialog.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(dialog, animated: true, completion: nil)
                    } else {
                        print("TODO更新成功")
                        let parentVC = self.presentingViewController as! TodoListViewController
                        //猪股
//                        parentVC.getTodoDataForFirestore1()
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    @IBAction func tapCloseButton(_ sender: Any) {
        if let presentationController = presentationController {
            presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
            self.dismiss(animated: true, completion: nil)
        }
        self.dismiss(animated: true, completion: nil)
    }
    // ③完了、未完了切り替えボタンの実装
    @IBAction func tapDoneButton(_ sender: Any) {
        if todoIsDone == true {
            if let user = Auth.auth().currentUser {
                Firestore.firestore().collection("users/\(user.uid)/todos").document(todoId).updateData(
                    [
                        //"isDone": !todoIsDone,
                        "isDone": false,
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
//                            if let presentationController = self.presentationController {
//                                presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
                                self.delegate?.delegateBool(keyWord: true)
//                                self.dismiss(animated: true, completion: nil)
//                            }
                        }
                    })
            }
        }
        if todoIsDone == false {
            if let user = Auth.auth().currentUser {
                Firestore.firestore().collection("users/\(user.uid)/todos").document(todoId).updateData(
                    [
                        //"isDone": !todoIsDone,
                        "isDone": true,
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
                            if let presentationController = self.presentationController {
//                                presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
                                self.delegate?.delegateBool(keyWord: false)
//                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    })
            }
        }
//        if let presentationController = presentationController {
//            presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
//            self.dismiss(animated: true, completion: nil)
//        }
    }
    
//        if todoIsDone == true {
//            if let user = Auth.auth().currentUser {
//                Firestore.firestore().collection("users/\(user.uid)/todos").document(todoId).updateData(
//                    [
//                        //"isDone": !todoIsDone,
//                        "isDone": false,
//                        "updatedAt": FieldValue.serverTimestamp()
//                    ]
//                    , completion: {_ in
//                    }
//                        error in
//                        if let error = error {
//                            print("TODO更新失敗: " + error.localizedDescription)
//                            let dialog = UIAlertController(title: "TODO更新失敗", message: error.localizedDescription, preferredStyle: .alert)
//                            dialog.addAction(UIAlertAction(title: "OK", style: .default))
//                            self.present(dialog, animated:  true, completion: nil)
//                        } else {
//                            print("TODO更新成功")
//                            if let presentationController = self.presentationController {
//                                presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
//                                self.delegate?.delegateBool(keyWord: true)
//                                self.dismiss(animated: true, completion: nil)
//                            }
//                        }
//                    })
//            }
//            if let presentationController = presentationController {
//                presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
//                self.dismiss(animated: true, completion: nil)
//            }
//        } else if todoIsDone == false {
//            if let user = Auth.auth().currentUser {
//                Firestore.firestore().collection("users/\(user.uid)/todos").document(todoId).updateData(
//                    [
//                        //"isDone": !todoIsDone,
//                        "isDone": true,
//                        "updatedAt": FieldValue.serverTimestamp()
//                    ]
//                    , completion: {
//                    }
//                        error in
//                        if let error = error {
//                            print("TODO更新失敗: " + error.localizedDescription)
//                            let dialog = UIAlertController(title: "TODO更新失敗", message: error.localizedDescription, preferredStyle: .alert)
//                            dialog.addAction(UIAlertAction(title: "OK", style: .default))
//                            self.present(dialog, animated:  true, completion: nil)
//                        } else {
//                            print("TODO更新成功")
//                            if let presentationController = self.presentationController {
//                                presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
//                                self.delegate?.delegateBool(keyWord: false)
//                                self.dismiss(animated: true, completion: nil)
//                            }
//                        }
//                    })
//            }
//            if let presentationController = presentationController {
//                presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
//                self.dismiss(animated: true, completion: nil)
//            }
//        }
//    }
    
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
                    let parentVC = self.presentingViewController as! TodoListViewController
                    //猪股
//                    parentVC.getTodoDataForFirestore1()
                    self.dismiss(animated: true, completion: nil)
                }
            }
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

}
