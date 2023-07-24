//
//  SplashViewController.swift
//  Todo
//
//  Created by ryo.inomata on 2023/07/12.
//

import UIKit
import Firebase

class SplashViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // ①アイコンを小さくする
        UIView.animate(withDuration: 0.5, delay: 0, animations: {
            self.imageView?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { bool in
            // ②アイコンを大きくする
            UIView.animate(withDuration: 0.2, delay: 0, animations: {
                self.imageView.transform = CGAffineTransform(scaleX: 20, y: 20)
            }) { bool in
                // ③ログイン状態によって、遷移先の選択
                if Auth.auth().currentUser != nil {
                    let storyboard: UIStoryboard = self.storyboard!
                    let next = storyboard.instantiateViewController(withIdentifier: "TodoListViewController")
                    self.present(next, animated: true, completion: nil)
                } else {
                    let storyboard: UIStoryboard = self.storyboard!
                    let next = storyboard.instantiateViewController(withIdentifier: "ViewController")
                    self.present(next, animated: true, completion: nil)
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
