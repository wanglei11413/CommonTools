//
//  CViewController.swift
//  CommonTools
//
//  Created by admin on 2023/8/14.
//

import UIKit

class CViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "C页面"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "diss", style: .done, target: self, action:#selector(diss))
    }
    
    @objc func diss() {
        self.dismiss(animated: true) {
            if let bb = self.dissMissBlock {
                bb()
            }
        }
    }
    
    
    typealias dissBlock = () -> ()
    
    public var dissMissBlock: dissBlock?

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
