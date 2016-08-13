//
//  SecondViewController.swift
//  ClassfitteriOS
//
//  Created by James Wood on 7/7/16.
//  Copyright © 2016 James Wood. All rights reserved.
//

import UIKit

class MeViewController: UIPageViewController, UIPageViewControllerDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self

        // Do any additional setup after loading the view, typically from a nib.

        let profileVC = self.viewControllerAtIndex(0)!
        self.setViewControllers([profileVC], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func viewControllerAtIndex(index: Int) -> UIViewController? {
        let profile = self.storyboard!.instantiateViewControllerWithIdentifier("ProfileViewController")
        return profile
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        return viewControllerAtIndex(0)
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        return viewControllerAtIndex(0)
    }

    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 1
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }

}
