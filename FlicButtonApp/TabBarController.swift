//
//  TabBarController.swift
//  FlicButtonApp
//
//  Created by Macbook on 11/8/17.
//  Copyright © 2017 Ayush. All rights reserved.
//

import UIKit
import CoreData

class TabBarController: UITabBarController {
    
    let coreDataStack = CoreDataStack()
    lazy var managedObjectContext: NSManagedObjectContext = {
        self.coreDataStack.managedObjectContext
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let tabBarViewControllers = self.viewControllers {
            if let navigationController = tabBarViewControllers[1] as? UINavigationController, let settingsController = navigationController.topViewController as? SettingsController {
                settingsController.managedObjectContext = self.managedObjectContext
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
