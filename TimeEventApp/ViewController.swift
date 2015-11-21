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
    var factor: Double = 0.0
    
    var startTime: NSDate = NSDate()
    var wikiSearchRecords:[String] = []
    
    @IBOutlet weak var totalTime: UITextField!
    @IBOutlet weak var refreshInterval: UITextField!
    @IBOutlet weak var percentage: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var textView: UITextView!
    
    
    @IBAction func stopButtonPressed(sender: UIButton) {
        timer.invalidate()
    }
    
    @IBAction func startButtonPressed(sender: UIButton) {
        wikiSearchRecords.removeAll()
        i = 0.0
        factor = 0.0
        textView.text = ""
        totalSeconds = Double(totalTime.text!)!
        eventPullingIntervalSeconds = Double(refreshInterval.text!)!
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
            factor = 0.0
        }
        factor++

        //when total amount of wait time passed, stop the timer
        if abs(startTime.timeIntervalSinceNow) > totalSeconds && counter >= 100 {
            timer.invalidate()
        }
    }

    func doTimeCalculation(base: Double) {
        let exp = 20.3444 * pow(base, 3.0) + 3
        //print(pow(M_E, exp) - e3)
        let yearInverval = pow(M_E, exp) - e3
        let historyDate = NSDate().dateByAddingTimeInterval(-yearInverval * 86400 * 365)
        print(historyDate)
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day], fromDate: historyDate)
        var year: Int = components.year
        let month: Int = components.month
        if abs(historyDate.timeIntervalSinceNow) > 2016*365*86400
        {
            textView.text.appendContentsOf("\(year) BC\n")
            year = -year
        }
        else
        {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "YYYY-MM"
            let historyDateString = dateFormatter.stringFromDate(historyDate)
            textView.text.appendContentsOf(historyDateString+"\n")
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

    func fetchWikiData(searchString: String) {
        //string is http://en.wikipedia.org/w/api.php?action=query&list=search&format=json&srsearch=year%201991%20BC&srwhat=text&srinfo=suggestion&srprop=snippet%7Csectionsnippet
        
        var searchResult: String = ""
        let _ = Alamofire.request(.GET, searchString)
            .responseJSON { response in
                if let value = response.result.value {
                    var searchResultList = (JSON(value))["query"]["search"]
                    if searchResultList.count != 0
                    {
                        let randomIndex: Int = (Int)(arc4random()) % searchResultList.count
                        searchResult = (String)(searchResultList[randomIndex])
                        self.textView.text.appendContentsOf(searchResult+"\n")
                    }
                    else
                    {
                        self.textView.text.appendContentsOf("no result\n")
                    }
                    self.textView.text.appendContentsOf("-----------------------------------------------\n")
                }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        progressBar.setProgress(0, animated: true)
        textView.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

