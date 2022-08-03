//
//  main.swift
//  cron-parser-challenge
//
//  Created by Mattia La Spina on 3/8/22.
//

import Foundation

while let line = readLine() {
    do {
        print(try Cron.parseLine(line))
    }catch Cron.CronError.HourArgument {
        print("Invalid Hour Argument.")
    } catch Cron.CronError.MinArgument {
        print("Invalid min Argument.")
    } catch Cron.CronError.HourConfig {
        print("Invalid Hour in Config file for this line")
    } catch Cron.CronError.MinConfig {
        print("Invalid min in Config file for this line")
    } catch {
        print("Unexpected error: \(error).")
    }
}

// MARK: Cron Main Class
/// Class with main functionality of parsing and arguments
class Cron {
    
    /// get Time Argument, get first parameter in case of fall back get de date of device
    /// - Returns: Hour in Sting HH:MM like 16:10
    static func getTimeArgument() -> String {
        if CommandLine.arguments.count < 2 {
            return TimeUtils.getTime()
        } else {
            return CommandLine.arguments[1]
        }
    }
    
    /// Parse Line from Config file and process for printing and throws errors in case of bad parameters
    /// - Parameter line: Line parameter have this structure MM HH /bin/cron_task  - Example:  30 1 /bin/run_me_daily
    /// - Returns: Return String of config file procesed like HH:MM day - /bin/cron_task  - Example: 1:30 tomorrow - /bin/run_me_daily
    static func parseLine(_ line:String) throws -> String {
        let timeArgument = getTimeArgument()
        
        let minArgument = timeArgument.components(separatedBy: ":")[1]
        let hourArgument = timeArgument.components(separatedBy: ":")[0]
        
        let minParameter = line.components(separatedBy: " ")[0]
        let hourParameter = line.components(separatedBy: " ")[1]
        
        let cronBinTask = line.components(separatedBy: " ")[2]
        
        try evaluateParameters(minParameter, hourParameter,minArgument,hourArgument)
        
        return evaluateAsterisk(hourArgument, hourParameter, minArgument, minParameter) + " - " + cronBinTask
    }
    
}

// MARK: Cron Evaluation and Errors
extension Cron {
    
    enum CronError: Error {
        case HourArgument
        case MinArgument
        case HourConfig
        case MinConfig
    }
    
    /// evaluate Asterisk in line of config file for retreving the correct time
    /// - Parameters:
    ///   - hour: Hour argument HH get form command line or date of device
    ///   - hourParameter: Hour Parameter HH get form line parsed of config file
    ///   - min: Minute argument MM get form command line or date of device
    ///   - minParameter: Minute Parameter MM get form line parsed of config file
    /// - Returns: Return String of config file procesed like HH:MM day - /bin/cron_task  - Example: 1:30 tomorrow - /bin/run_me_daily
    static func evaluateAsterisk(_ hour: String, _ hourParameter: String, _ min: String, _ minParameter: String) -> String {
        if (hourParameter == "*" && minParameter == "*"){
            return "\(hour):\(min) today"
        } else if (hourParameter == "*" && minParameter != "*") {
            return TimeUtils.evaluateHourHounrlyRepeating(Int(hour)!, Int(min)!, Int(minParameter)!) + ":\(minParameter) " + TimeUtils.evaluateIsTodayHounrlyRepeating(Int(hour)!, Int(min)!, Int(minParameter)!)
        } else if (hourParameter != "*" && minParameter == "*") {
            return "\(hourParameter):00 " + TimeUtils.evaluateIsTodayOnSixty(Int(hour)!,Int(hourParameter)!)
        }else{
            return "\(hourParameter):\(minParameter) " + TimeUtils.evaluateIsTodayWithHoursAndMin(Int(hour)!, Int(hourParameter)!, Int(min)!, Int(minParameter)!)
        }
    }
    
    /// evaluate Parameters to make sure it comes hours and minutes or asterisks
    /// - Parameters:
    ///   - minParameter: Minute Parameter MM get form line parsed of config file
    ///   - hourParameter: Hour Parameter HH get form line parsed of config file
    ///   - minArgument: Minute argument MM get form command line or date of device
    ///   - hourArgument: Hour argument HH get form command line or date of device
    static func evaluateParameters(_ minParameter: String, _ hourParameter: String,_ minArgument: String, _ hourArgument: String) throws {
        if isMinuteParameterCorrect(minParameter) {
            throw CronError.MinConfig
        }
        
        if isHourParameterCorrect(hourParameter) {
            throw CronError.HourConfig
        }
        
        if !(Int(minArgument) ?? -1 >= 0 || Int(minArgument) ?? 99 < 60) {
            throw CronError.HourArgument
        }
        
        if !(Int(hourArgument) ?? -1 >= 0 || Int(hourArgument) ?? 99 < 24) {
            throw CronError.MinArgument
        }
    }
    
    /// To be sure that it comes valid hours or an asterisk
    /// - Parameter hourConfig: Hour Parameter HH get form line parsed of config file
    /// - Returns: Bool True or False
    static func isHourParameterCorrect(_ hourConfig: String)  -> Bool {
        return !(hourConfig == "*" || Int(hourConfig) ?? -1 >= 0 || Int(hourConfig) ?? 99 < 24)
    }
    
    /// To be sure that it comes valid Minute or an asterisk
    /// - Parameter minConfig: Minute Parameter MM get form line parsed of config file
    /// - Returns: Bool True or False
    static func isMinuteParameterCorrect(_ minConfig: String)  -> Bool {
        return !(minConfig == "*" || Int(minConfig) ?? -1 >= 0 || Int(minConfig) ?? 99 < 60)
    }
    
}

// MARK: TimeUtils
/// Class with main functionality of time and days
class TimeUtils {
    
    /// Function that detects if the execution time is today or tomorrow
    /// - Parameters:
    ///   - hour: Hour argument HH get form command line or date of device
    ///   - hourParameter: Hour Parameter HH get form line parsed of config file
    /// - Returns: "tomorrow" or "today"
    static func evaluateIsTodayOnSixty(_ hour: Int, _ hourParameter: Int) -> String {
        return (hour > hourParameter) ? "tomorrow" : "today"
    }
    
    
    /// detects if the execution time can be at the same time, within an hour or within an hour the next day
    /// - Parameters:
    ///   - hour: Hour argument HH get form command line or date of device
    ///   - min: Minute argument MM get form command line or date of device
    ///   - minParameter: Minute Parameter MM get form line parsed of config file
    /// - Returns: The execution hour time
    static func evaluateHourHounrlyRepeating(_ hour: Int, _ min: Int, _ minParameter: Int) -> String {
        if (hour == 23 && min > minParameter) {
            return "00"
        } else if (min > minParameter){
            return String(hour+1)
        } else{
            return String(hour)
        }
    }
    
    /// Detects if the hourly execution can be carried out today, since if it is after 23:00 it would have to be carried out the following day
    /// - Parameters:
    ///   - hour: Hour argument HH get form command line or date of device
    ///   - min: Minute argument MM get form command line or date of device
    ///   - minParameter: Minute Parameter MM get form line parsed of config file
    /// - Returns: "tomorrow" or "today" string
    static func evaluateIsTodayHounrlyRepeating(_ hour: Int, _ min: Int, _ minParameter: Int) -> String {
        return (hour == 23 && min > minParameter) ? "tomorrow" : "today"
    }
    
    /// Detect if the daily execution task can be done today or tomorrow
    /// - Parameters:
    ///   - hour: Hour argument HH get form command line or date of device
    ///   - hourParameter: Hour Parameter HH get form line parsed of config file
    ///   - min: Minute argument MM get form command line or date of device
    ///   - minParameter: Minute Parameter MM get form line parsed of config file
    /// - Returns: "tomorrow" or "today" string
    static func evaluateIsTodayWithHoursAndMin(_ hour: Int, _ hourParameter: Int, _ min: Int, _ minParameter: Int) -> String{
        if (hour > hourParameter) {
            return "tomorrow"
        } else if (hour < hourParameter){
            return "today"
        } else {
            return min > minParameter ? "tomorrow" : "today"
        }
    }
    
    /// Returns the formatted device time
    /// - Returns: The device time in String HH:mm - Example 16:10
    static func getTime() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let result = dateFormatter.string(from: Date())
        return result
    }
    
}
