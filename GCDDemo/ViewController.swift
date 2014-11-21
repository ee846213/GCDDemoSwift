//
//  ViewController.swift
//  GCDDemo
//
//  Created by 卓哥的世界你不懂 on 14/11/20.
//  Copyright (c) 2014年 李卓. All rights reserved.
//

import UIKit
class ViewController: UIViewController {

    @IBOutlet var topLabel: UILabel!
    @IBOutlet var midLabel: UILabel!
    @IBOutlet var belowlabel: UILabel!
    @IBOutlet var baseLabel: UILabel!
    var topHP:Int = 1000
    var midHP:Int = 1000
    var belowHP:Int = 1000
    var baseHP:Int = 3000
    var alertView:UIAlertView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func sameTimeAttack(sender: UIButton) {
        
        
        
        //并发执行
        let group = dispatch_group_create();
        let queue = dispatch_queue_create("com.lex.GCDDemo.sameTimeQueue", DISPATCH_QUEUE_CONCURRENT)
        dispatch_group_async(group, queue) { () -> Void in
            self.attackTower(self.topHP, _label: self.topLabel)
            
        }
        dispatch_group_async(group, queue) { () -> Void in
            self.attackTower(self.midHP, _label: self.midLabel)
        }
        
        dispatch_group_async(group, queue) { () -> Void in
            self.attackTower(self.belowHP, _label: self.belowlabel)
        }
        //塔破完后，进攻基地
        dispatch_barrier_async(queue, { () -> Void in
            self.attackTower(self.baseHP, _label: self.baseLabel)
        })
        dispatch_group_notify(group, queue) { () -> Void in
            self.showAlertView()
        }

    }
    @IBAction func inSequence(sender: AnyObject) {
        //串行执行
        let group = dispatch_group_create()
        let queue = dispatch_queue_create("com.lex.GCDDemo.inSquenceQueue", nil);
        dispatch_group_async(group, queue) { () -> Void in
            self.attackTower(self.topHP, _label: self.topLabel)
            
        }
        dispatch_group_async(group, queue) { () -> Void in
            self.attackTower(self.midHP, _label: self.midLabel)
        }
        
        dispatch_group_async(group, queue) { () -> Void in
            self.attackTower(self.belowHP, _label: self.belowlabel)
        }
        //塔破完后，进攻基地
        dispatch_barrier_async(queue, { () -> Void in
            self.attackTower(self.baseHP, _label: self.baseLabel)
        })
        dispatch_group_notify(group, queue) { () -> Void in
            self.showAlertView()
        }
        
    }
    func attackTower(_hp:Int,_label:UILabel)
    {
        var hp = _hp
        var label = _label
        while hp>0
        {
            hp--
            NSLog("base=%d", hp)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                _label.text = "\(hp)"
                if hp==0
                {
                    label.text = "破"
                }
            })
        }
    }
    func showAlertView()
    {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.alertView = UIAlertView(title: "提示", message: "防御塔全破", delegate: self, cancelButtonTitle: "取消")
            self.alertView.show()
        })
        //创建一个GCD的计时器来自动消失alertview
        let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0))
        //设置timer
        //                dispatch_source_set_timer(timer, dispatch_walltime(nil, 0), 2*NSEC_PER_SEC, 0)
        dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, 0), 2*NSEC_PER_SEC, 0)
        var num = 0
        
        //方法会在开始执行一次，然后每隔2秒再执行
        dispatch_source_set_event_handler(timer, { () -> Void in
            
            
            if num>0
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.alertView.dismissWithClickedButtonIndex(0, animated: true)
                })
                //第二次执行停止计时器
                dispatch_suspend(timer);
            }
            num++
            
        })
        dispatch_resume(timer);


    }
    @IBAction func reset(sender: AnyObject) {
        midLabel.text = ""
        topLabel.text = ""
        belowlabel.text = ""
        baseLabel.text = ""
        belowHP = 1000;
        topHP = 1000;
        midHP = 1000;
        baseHP = 1000;
    }
    
    /**
    延迟执行
    
    :param: delay 延迟时间
    */
    func delayPerform(delay:NSTimeInterval)
    {
        let delaytime = delay * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delaytime))
        
        dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
            println("延迟执行");
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

