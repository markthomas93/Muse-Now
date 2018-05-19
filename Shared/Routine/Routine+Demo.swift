//  Routine+Demo.swift
//  MuseNow
//
//  Created by warren on 3/18/18.
//  Copyright © 2018 Muse. All rights reserved.

import Foundation

extension Routine {
    
    func makeDemoRoutine() {

        Log ("⧉ Routine::\(#function) ")
        var items = [RoutineItem]()
        var categories = [String]()
        catalog.removeAll()

        func add(_ dow:Int,_ bgnHours:Float, _ durHours:Float,_ category:String, _ title: String) {

            var colors = [String:UInt32]()
            colors["Rest"]   = MuColor.makeTypeColor(.purple)
            colors["Meal"]   = MuColor.makeTypeColor(.green)
            colors["Study"]  = MuColor.makeTypeColor(.yellow)
            colors["Work"]   = MuColor.makeTypeColor(.orange)
            colors["Health"] = MuColor.makeTypeColor(.violet)

            let item = RoutineItem(dow, bgnHours, durHours, category, title)
            items.append(item)

            if let routineCategory = catalog[category] {
                routineCategory.items.append(item)
            }
            else {
                if let color = colors[category] {
                    catalog[category] = RoutineCategory(category, item, color)
                }
            }
        }

        add(0b1111111, 22.0, 8.0, "Rest","Sleep")       // "Sleep from 10 pm to 8 am every day"
        add(0b1111111,  7.0, 0.5, "Meal","Breakfast")   // "Breakfast from 7 to 7:30 am on week days"
        add(0b0111110, 12.0, 1.0, "Meal","Lunch")       // "Lunch from noon to 1 pm on week days"
        add(0b0111100, 18.0, 1.0, "Meal","Dinner")      // "Dinner from 6 to 7 pm from monday to thursday "
        add(0b0111100, 19.0, 1.0, "Study","Study")      // "Study from 7 to 8 pm on sunday through thursday"
        add(0b0001000, 15.0, 1.0, "Study","Quiz")       // "Quiz on Wednesday at 3"
        add(0b0000010, 12.0, 1.0, "Study","Test")       // "Test on Friday at 3"
        add(0b0111111,  9.0, 3.0, "Work","Work")        // "Work from 9 to 12 on weekdays"
        add(0b0000001,  9.0, 3.0, "Work","Work")        // "Work from 9 to 12 on on saturday"
        add(0b0001010, 13.0, 2.0, "Work","Work")        // "Work from 1 to 3 on wednesday and thursday"
        add(0b0110100, 13.0, 3.0, "Work","Work")        // "Work from 1 to 4 on monday, tuesday, thursday"
        add(0b0101000, 17.5, 2.5, "Health","Stretch")   // "Stretch from 5:30 to 8 pm on monday and tuesday"
        add(0b1000000,  8.0, 4.0, "Health","Bike")      // "Bike from 8 to 2 on sunday"
        add(0b1000000, 16.0, 2.0, "Health","Stretch")   // "Stretch from 4 to 6 pm on sunday"
        add(0b0010001, 16.0, 2.0, "Health","Weights")   // "Weights from 4p to 6 on Tuesday"
    }

    func getDemoEvents(completion: @escaping (_ result:[MuEvent]) -> Void)  {

        Log ("⧉ Routine::\(#function) ")
        catalog.removeAll()
        makeDemoRoutine()
        completion(filteredEvents())
    }


}


