//
//  TutorialViewController.swift
//  TicSong_Media
//
//  Created by 전한경 on 2017. 1. 16..
//  Copyright © 2017년 jeon. All rights reserved.
//

import UIKit

class TutorialViewController: UIPageViewController,UIPageViewControllerDataSource {
    
    var arrPagePhoto: NSArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arrPagePhoto = ["tutorial1", "tutorial2", "tutorial3", "tutorial4", "tutorial5"];
        self.dataSource = self
        self.setViewControllers([getViewControllerAtIndex(0)] as [UIViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
    }
    
    // MARK:- Other Methods
    func getViewControllerAtIndex(_ index: NSInteger) -> TutorialContentViewController{
        // Create a new view controller and pass suitable data.
        let pageContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "TutorialContentViewController") as! TutorialContentViewController
        if((arrPagePhoto.count == 0) || (index >= arrPagePhoto.count)){
            return TutorialContentViewController()
        }
        pageContentViewController.PhotoName = "\(arrPagePhoto[index])"
        pageContentViewController.pageIndex = index
        return pageContentViewController
    }
    
    
    
    // MARK:- UIPageViewControllerDataSource Methods
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?{
        let pageContent: TutorialContentViewController = viewController as! TutorialContentViewController
        
        var index = pageContent.pageIndex
        
        if ((index == 0) || (index == NSNotFound)){
            return nil
        }
        
        index -= 1;
        return getViewControllerAtIndex(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?{
        let pageContent: TutorialContentViewController = viewController as! TutorialContentViewController
        
        var index = pageContent.pageIndex
        if (index == NSNotFound){
            return nil
        }
        
        index += 1;
        
        if(index == arrPagePhoto.count){
            return nil
        }
        
        return getViewControllerAtIndex(index)
    }
    
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return arrPagePhoto.count
    }
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
