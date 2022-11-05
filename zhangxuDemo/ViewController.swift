//
//  ViewController.swift
//  zhangxuDemo
//
//  Created by bytedance on 2022/10/23.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        var containerView = UIView()
        var subView1 = UIView()
        var subView2 = UIView()
        
        containerView.backgroundColor = .blue
        subView1.backgroundColor = .yellow
        subView2.backgroundColor = .red
        
        self.view.flex.define { flex in
            flex.addView(containerView)
        }
        
        var containerItem = FlexItem()
        var subItem1 = FlexItem()
        var subItem2 = FlexItem()
        
        containerItem.flex.width(100).left(50).top(200)

        subItem1.flex.height(100).width(50)
        subItem2.flex.height(200).width(40)
        
        containerItem.flex.define { flex in
            flex.addItem(subItem1)
            flex.addItem(subItem2)
        }
        
        containerItem.flex.layout(mode: .adjustHeight)
        
        
        containerView.flex.define { flex in
            flex.addView(subView1)
            flex.addView(subView2)
        }
        
        containerView.frame = containerItem.frame
        subView1.frame = subItem1.frame
        subView2.frame = subItem2.frame
        
        self.view.flex.layout(mode: .adjustHeight)
    }


}
