//
//  ViewController.swift
//  TimeEventApp
//
//  Created by Guanyi Fang on 2015-11-13.
//  Copyright © 2015 Guanyi Fang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let e3: Double = pow(M_E, 3.0)
    var i = 0.0
    var timer: NSTimer =  NSTimer()
    
    @IBOutlet weak var totalTime: UITextField!
    @IBOutlet weak var refreshInterval: UITextField!
    @IBOutlet weak var percentage: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!

    @IBAction func startButtonPressed(sender: UIButton) {
        percentage.text = "0%"
        self.counter = 0
        for  _ in 1...100 {
            let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 2 * Int64(NSEC_PER_SEC))
            
            dispatch_after(time, dispatch_get_main_queue()) {
                
                self.counter++
            }
        }
    }
    
    var counter:Int = 0 {
        didSet {
            let progress = Float(counter) / 100.0
            let animated = counter != 0
            progressBar.setProgress(progress, animated: animated)
            percentage.text = ("\(counter)%")
        }
    }
    
    func timerRun() {
        let refreshInterval: Double = 1
        let totalMinutes: Double = 15
        
        
        let percentage : Double = refreshInterval / totalMinutes
        //var exp : Double = 0.0
        
        //for var i = 0.0; i <= 1; i+=percentage {
        
        //}
        i = i + percentage
        perform(i)
    }
    
    func perform(i: Double) {
        let exp = 20.3444 * pow(i, 3.0) + 3
        print(pow(M_E, exp) - e3)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "timerRun", userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

