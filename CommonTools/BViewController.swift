//
//  BViewController.swift
//  CommonTools
//
//  Created by admin on 2023/8/14.
//

import UIKit

class BViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "B页面"

        let vc = CViewController()
        vc.dissMissBlock = {
            self.navigationController?.popViewController(animated: false)
        }
        self.present(vc, animated: false)
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
