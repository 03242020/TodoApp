//
//  TodoListViewController.swift
//  Todo
//
//  Created by ryo.inomata on 2023/07/13.
//

import UIKit
import Firebase

//日付と時間を項目を追加してそれらの選択が
class TodoListViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    private var sendKeyWord: Bool?
    //    {
    //        didSet {
    //            isDone = sendKeyWord
    //            getTodoDataForFirestore()
    //            print("着地")
    //        }
    //    }
    
    // Firestoreから取得するTodoのid,title,detail,idDoneを入れる配列を用意
    var todoIdArray: [String] = []
    var todoTitleArray: [String] = []
    var todoDetailArray: [String] = []
    var todoIsDoneArray: [Bool] = []
    // 画面下部の未完了、完了済みを判定するフラグ(falseは未完了)
    var isDone: Bool? = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        configureRefreshControl()
        
        // Do any additional setup after loading the view.
    }
    //     モーダルから戻ってきた時はviewWillAppear(:)が呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // ①ログイン済みかどうか確認
        if let user = Auth.auth().currentUser {
            // ②ログインしているユーザー名の取得
            Firestore.firestore().collection("users").document(user.uid).getDocument(completion: {(snapshot,error) in
                if let snap = snapshot {
                    if let data = snap.data() {
                        self.userNameLabel.text = data["name"] as? String
                    }
                } else if let error = error {
                    print("ユーザー名取得失敗: " + error.localizedDescription)
                }
            })
            Firestore.firestore().collection("users/\(user.uid)/todos").whereField("isDone", isEqualTo: isDone).order(by: "createdAt").addSnapshotListener({ (querySnapshot, error) in
                if let querySnapshot = querySnapshot {
                    var idArray:[String] = []
                    var titleArray:[String] = []
                    var detailArray:[String] = []
                    var isDoneArray:[Bool] = []
                    for doc in querySnapshot.documents {
                        let data = doc.data()
                        idArray.append(doc.documentID)
                        titleArray.append(data["title"] as! String)
                        detailArray.append(data["detail"] as! String)
                        isDoneArray.append(data["isDone"] as! Bool)
                    }
                    self.todoIdArray = idArray
                    self.todoTitleArray = titleArray
                    self.todoDetailArray = detailArray
                    self.todoIsDoneArray = isDoneArray
                    self.tableView.reloadData()
                } else if let error = error {
                    print("TODO取得失敗: " + error.localizedDescription)
                }
            })
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoTitleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = todoTitleArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard: UIStoryboard = self.storyboard!
        let next = storyboard.instantiateViewController(withIdentifier: "TodoEditViewController") as! TodoEditViewController
        next.todoId = todoIdArray[indexPath.row]
        next.todoTitle = todoTitleArray[indexPath.row]
        next.todoDetail = todoDetailArray[indexPath.row]
        next.todoIsDone = todoIsDoneArray[indexPath.row]
        // delegateを自身に委任
        next.modalPresentationStyle = .overFullScreen
        next.presentationController?.delegate = self
        next.delegate = self
        //        self.present(next, animated: true)
        self.present(next, animated: true, completion: nil)
    }
    // スワイプ時のアクションを設定するメソッド
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal,
                                            title: "Edit",
                                            handler: {(action: UIContextualAction, view: UIView, completion: (Bool) -> Void) in
            if let user = Auth.auth().currentUser {
                Firestore.firestore().collection("users/\(user.uid)/todos").document(self.todoIdArray[indexPath.row]).updateData(
                    [
                        "isDone": !self.todoIsDoneArray[indexPath.row],
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
                            //猪股
                            //                        self.getTodoDataForFirestore1()
                        }
                    })
            }
        })
        editAction.backgroundColor = UIColor(red: 101/255.0, green: 198/255.0, blue: 187/255.0, alpha: 1)
        // controlの値によって表示するアイコンを切り替え
        switch isDone {
        case true:
            editAction.image = UIImage(systemName: "arrowshape.turn.up.left")
        default:
            editAction.image = UIImage(systemName: "checkmark")
        }
        
        // 削除のスワイプ
        let deleteAction = UIContextualAction(style: .normal, title: "Delete", handler: { (action: UIContextualAction, view:UIView, completion: (Bool) -> Void) in
            if let user = Auth.auth().currentUser {
                Firestore.firestore().collection("users/\(user.uid)/todos").document(self.todoIdArray[indexPath.row]).delete(){ error in
                    if let error = error {
                        print("TODO削除失敗: " + error.localizedDescription)
                        let dialog = UIAlertController(title: "TODO削除失敗", message: error.localizedDescription, preferredStyle: .alert)
                        dialog.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(dialog, animated: true, completion: nil)
                    } else {
                        print("TODO削除成功")
                        //ここ変更しないで済んだのは何故？
                        //猪股
                        //                        self.getTodoDataForFirestore1()
                    }
                }
            }
        })
        deleteAction.backgroundColor = UIColor(red: 214/255.0, green: 69/255.0, blue: 65/255.0, alpha: 1)
        deleteAction.image = UIImage(systemName: "clear")
        
        // スワイプアクションを追加
        let swipeActionConfig = UISwipeActionsConfiguration(actions: [editAction, deleteAction])
        // fullスワイプ時に挙動が起きない様に制御
        swipeActionConfig.performsFirstActionWithFullSwipe = false
        
        return swipeActionConfig
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func tapAddButton(_ sender: Any) {
        // ①Todo作成画面に画面遷移
        let storyboard: UIStoryboard = self.storyboard!
        let next = storyboard.instantiateViewController(withIdentifier: "TodoAddViewController")
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated:  true, completion: nil)
        // モーダル閉じた際にGETしてRELOADするよう調整したが、別クラスでメソッド呼び出しで解決した。
        // let modalViewController = self.storyboard?.instantiateViewController(withIdentifier: "TodoAddViewController") as! TodoAddViewController
        // modalViewController.presentationController?.delegate = self
        // present(modalViewController, animated: true, completion: nil)
    }
    
    // エラーの内容、インデックスを追加する方法URL
    // やり方Googleで検索して参考にして対応
    // TavleViewのリロードされる前の部分なのでFirebaseが怪しい
    //
    @IBAction func tapLogoutButton(_ sender: Any) {
        // ①ログイン済みかどうか確認
        if Auth.auth().currentUser != nil {
            // ②ログアウトの処理
            do {
                try Auth.auth().signOut()
                print("ログアウト完了")
                // ③成功した場合はログイン画面へ遷移
                let storyboard: UIStoryboard = self.storyboard!
                let next = storyboard.instantiateViewController(withIdentifier: "ViewController")
                self.present(next, animated: true, completion: nil)
            } catch let error as NSError {
                print("ログアウト失敗:" + error.localizedDescription)
                // ②が失敗した場合
                let dialog = UIAlertController(title: "ログアウト失敗", message: error.localizedDescription, preferredStyle: .alert)
                dialog.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(dialog, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func changeDoneControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            isDone = false
            if let user = Auth.auth().currentUser {
                Firestore.firestore().collection("users/\(user.uid)/todos").whereField("isDone", isEqualTo: isDone).order(by: "createdAt").addSnapshotListener({ (querySnapshot, error) in
                    if let querySnapshot = querySnapshot {
                        var idArray:[String] = []
                        var titleArray:[String] = []
                        var detailArray:[String] = []
                        var isDoneArray:[Bool] = []
                        for doc in querySnapshot.documents {
                            let data = doc.data()
                            idArray.append(doc.documentID)
                            titleArray.append(data["title"] as! String)
                            detailArray.append(data["detail"] as! String)
                            isDoneArray.append(data["isDone"] as! Bool)
                        }
                        self.todoIdArray = idArray
                        self.todoTitleArray = titleArray
                        self.todoDetailArray = detailArray
                        self.todoIsDoneArray = isDoneArray
                        self.tableView.reloadData()
                        
                    } else if let error = error {
                        print("TODO取得失敗: " + error.localizedDescription)
                    }
                })
            }
        case 1:
            //            if isDone == nil {
            isDone = true
            //            }
            if let user = Auth.auth().currentUser {
                Firestore.firestore().collection("users/\(user.uid)/todos").whereField("isDone", isEqualTo: isDone).order(by: "createdAt").addSnapshotListener({ (querySnapshot, error) in
                    if let querySnapshot = querySnapshot {
                        var idArray:[String] = []
                        var titleArray:[String] = []
                        var detailArray:[String] = []
                        var isDoneArray:[Bool] = []
                        for doc in querySnapshot.documents {
                            let data = doc.data()
                            idArray.append(doc.documentID)
                            titleArray.append(data["title"] as! String)
                            detailArray.append(data["detail"] as! String)
                            isDoneArray.append(data["isDone"] as! Bool)
                        }
                        self.todoIdArray = idArray
                        self.todoTitleArray = titleArray
                        self.todoDetailArray = detailArray
                        self.todoIsDoneArray = isDoneArray
                        self.tableView.reloadData()
                        
                    } else if let error = error {
                        print("TODO取得失敗: " + error.localizedDescription)
                    }
                })
            }
            // ないとエラーになるので定義している
        default:
            //            isDone = false
            //            getTodoDataForFirestore()
            print("test")
        }
    }
    
    // FirestoreからTodoを取得する処理
    func getTodoDataForFirestore1() {
        if let user = Auth.auth().currentUser {
            Firestore.firestore().collection("users/\(user.uid)/todos").whereField("isDone", isEqualTo: isDone).order(by: "createdAt").addSnapshotListener({ (querySnapshot, error) in
                if let error = error {
                    print("TODO取得失敗: " + error.localizedDescription)
                } else {
                    if let querySnapshot = querySnapshot {
                        var idArray:[String] = []
                        var titleArray:[String] = []
                        var detailArray:[String] = []
                        var isDoneArray:[Bool] = []
                        for doc in querySnapshot.documents {
                            let data = doc.data()
                            idArray.append(doc.documentID)
                            titleArray.append(data["title"] as! String)
                            detailArray.append(data["detail"] as! String)
                            isDoneArray.append(data["isDone"] as! Bool)
                        }
                        self.todoIdArray = idArray
                        self.todoTitleArray = titleArray
                        self.todoDetailArray = detailArray
                        self.todoIsDoneArray = isDoneArray
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
    //なぜ下記記述では上手く動作しないのか
    //        if let user = Auth.auth().currentUser {
    //            Firestore.firestore().collection("users/\(user.uid)/todos").whereField("isDone", isEqualTo: isDone).order(by: "createdAt").getDocuments(completion: { (QuerySnapshot, error) in
    //                if let QuerySnapshot = QuerySnapshot {
    //                    var idArray:[String] = []
    //                    var titleArray:[String] = []
    //                    var detailArray:[String] = []
    //                    var isDoneArray:[Bool] = []
    //                    for doc in QuerySnapshot.documents {
    //                        let data = doc.data()
    //                        idArray.append(doc.documentID)
    //                        titleArray.append(data["title"] as! String)
    //                        detailArray.append(data["detail"] as! String)
    //                        isDoneArray.append(data["isDone"] as! Bool)
    //                    }
    //                    self.todoIdArray = idArray
    //                    self.todoTitleArray = titleArray
    //                    self.todoDetailArray = detailArray
    //                    self.todoIsDoneArray = isDoneArray
    //                    print(self.todoTitleArray)
    //                    self.tableView.reloadData()
    //
    //                } else if let error = error {
    //                    print("TODO取得失敗: " + error.localizedDescription)
    //                }
    //            })
    
    
    func configureRefreshControl () {
        //RefreshControlを追加する処理
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    @objc func handleRefreshControl() {
        getTodoDataForFirestore1()
        DispatchQueue.main.async {
            //            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
            self.view.endEditing(true)
        }
    }
}

// 動作確認できなかった。
// let parentVC = self.presentingViewController as! TodoListViewController
// parentVC.getTodoDataForFirestore()
// 上記で解決
extension TodoListViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("VC didDismiss")
        if sendKeyWord == false {
            isDone = false
            getTodoDataForFirestore1()
        }
        if sendKeyWord == true {
            isDone = true
            getTodoDataForFirestore1()
        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
//            print("0.15秒経ちました。")
//            self.getTodoDataForFirestore()
//        }
        
    }
}

extension TodoListViewController: KeyWordInputDelegate {
    func delegateBool(keyWord: Bool) {
        self.sendKeyWord = keyWord
    }
}
