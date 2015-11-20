//
//  ViewController.swift
//  TimeEventApp
//
//  Created by Guanyi Fang on 2015-11-13.
//  Copyright © 2015 Guanyi Fang. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
    
    let e3: Double = pow(M_E, 3.0)
    var i = 0.0
    var timer: NSTimer =  NSTimer()
    var totalSeconds: Double = 0.0
    var eventPullingIntervalSeconds: Double = 0.0
    var enentPullingProgressPercentage: Double = 0.0
    var afterHowManyTimerCountsPullEventOnce: Double = 0.0
    var factor: Double = 1.0
    
    var startTime: NSDate = NSDate()
    
    @IBOutlet weak var totalTime: UITextField!
    @IBOutlet weak var refreshInterval: UITextField!
    @IBOutlet weak var percentage: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!

    @IBAction func startButtonPressed(sender: UIButton) {
        //let totalSeconds: Double = Double(totalTime.text!)!
        //let eventPullingIntervalSeconds: Double = Double(refreshInterval.text!)!
        
        totalSeconds = 100.0;
        eventPullingIntervalSeconds = 10.0
        enentPullingProgressPercentage = eventPullingIntervalSeconds / totalSeconds
        percentage.text = "0%"
        self.counter = 0
        
        //This program sets progress bar each time updates 1% of the total wait time
        //If the total wait time is 400 seconds, then after each 4 seconds, the NSTimer
        //will fire the "timerRun()" function once to update the bar and the percentage UILabel
        let secondsOfOnePercentProgress = totalSeconds / 100
        
        //The number of event pulling operation is not the same as NSTimer fires the "timerRun" function
        //Based on the following formular, there is a relationship between how often the event pulling
        //operation should be performed and how many secnonds are there in 1% of the total wait time
        afterHowManyTimerCountsPullEventOnce = eventPullingIntervalSeconds / secondsOfOnePercentProgress
        
        startTime = NSDate()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(secondsOfOnePercentProgress, target: self, selector: "timerRun", userInfo: nil, repeats: true)
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
        //increment counter variable will trigger the counter "didSet property method"
        self.counter++
        
        if factor >= floor(afterHowManyTimerCountsPullEventOnce) {
            i = i + enentPullingProgressPercentage
            doTimeCalculation(i)
            factor = 1.0
        }
        factor++
        
        if abs(startTime.timeIntervalSinceNow) > totalSeconds {
            timer.invalidate()
        }
    }
    
    func doTimeCalculation(base: Double) {
        let exp = 20.3444 * pow(base, 3.0) + 3
        //print(pow(M_E, exp) - e3)
        let yearInverval = pow(M_E, exp) - e3
        let historyDate = NSDate().dateByAddingTimeInterval(-yearInverval * 86400)
        print(historyDate)
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day], fromDate: historyDate)
        //print(String(components.year) + " " + String(components.month) + " " + String(components.date))
        var year: Int = components.year
        var month: Int = components.month
        //let originDate: NSDate = NSDate(timeIntervalSinceNow: -2016*365*86400)
        //print("Origin:  \(originDate)")
        //print(abs(historyDate.timeIntervalSinceNow) > 2016*365*86400)
        if abs(historyDate.timeIntervalSinceNow) > 2016*365*86400
        {
            year = -year
        }
        
        fetchWikiData(buildSearchString(year, month: month))
    }
    
    func buildSearchString(var year: Int, month: Int)->String{
        let searchStringFirstPart: String = "http://en.wikipedia.org/w/api.php?action=query&list=search&format=json&srsearch="
        let serchStringSecondPart: String = "&srwhat=text&srinfo=suggestion&srprop=snippet%7Csectionsnippet"
        var searchString: String = ""
        if year > 0
        {
            searchString = searchStringFirstPart + "Year%20\(year)%20Month%20\(month)" + serchStringSecondPart
        }
        else
        {
            year = -year
            searchString = searchStringFirstPart + "Year%20\(year)%20BC" + serchStringSecondPart
        }
        
        return searchString
    }
    
    func fetchWikiData(searchString: String) -> String {
        //print(searchString)
        //string is http://en.wikipedia.org/w/api.php?action=query&list=search&format=json&srsearch=year%201991%20BC&srwhat=text&srinfo=suggestion&srprop=snippet%7Csectionsnippet
        let request = Alamofire.request(.GET, searchString)
            .responseJSON { response in
                if let value = response.result.value {
                    //print("JSON: \(value)")
                    var searchResultList = (JSON(value))["query"]["search"]
                    if searchResultList.count != 0
                    {
                        let randomIndex: Int = (Int)(arc4random()) % searchResultList.count
                        print(searchResultList[randomIndex])
                    }
                    else
                    {
                        print("no result")
                    }
                }
        }
        return ""
    }
    
    func yearConverter(yearInDouble: Double)->String {
        return ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        progressBar.setProgress(0, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

