//
//  MyCollectionViewController.swift
//  collectionDemo
//
//  Created by minh ho on 9/27/17.
//  Copyright © 2017 minh ho. All rights reserved.
//

import UIKit
import Foundation
import Kingfisher

private let reuseIdentifier = "MyCell"

class MyCollectionViewController: UICollectionViewController {
    //MARK: Private Variables
    //contains titles of urls obtained from parsing json, should be the names? might need to add .png to all of them.
    var titlesArray = [String]()
    var urlsArray = [String]()
    var imageArray = [UIImage]()
    //MARK: Private Functions
    
    //Function to return json of given subreddit, parse urls, and add urls to private Array
    func getHttpRequest(UrlStringOfSubreddit: String){
        guard let url = URL(string: UrlStringOfSubreddit) else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error == nil {
                if let data = data {
                    let json: [String:AnyObject]!
                    do
                    {
                        json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                    }
                    catch
                    {
                        return
                    }
                    
                    // var urlsArray = [String]()
                    // var titlesArray = [String]()
                    if let dataDic = json["data"] as? [String:AnyObject],
                        let dataArray = dataDic["children"] as? [[String:AnyObject]]{
                        for index in 0...20{
                            let url = dataArray[index]["data"]!["url"]! as! String
                            let title = dataArray[index]["data"]!["title"]! as! String
                            self.urlsArray.append(url)
                            self.titlesArray.append(title)
                        }
                        print(self.urlsArray)
                        print("\n")
                        print(self.titlesArray)
                    }
                    
                }
            }
        }
        task.resume()
    }
    //Function to create an image from a url, and then append to array of UIImages?
    func setImageFromUrl(StringContainingUrl url: String){
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //configure images to be stored in a nsurlcache
//        let memoryCapacity = 500 * 1024 * 1024
//        let diskCapacity = 500 * 1024 * 1024
//        let urlCache = NSURLCache(memoryCapacity: memoryCapacity, diskCapacity, diskCapacity: "myDiskPath")
//        NSURLCache.setSharedURLCache(urlCache)
        
        var subReddit: String = "https://reddit.com/r/earthPorn/.json"
        getHttpRequest(UrlStringOfSubreddit: subReddit)
        //calling above function will instantiate urlsArray to be an array of urls of images.
        //then must figure out how to turn urls into images.

        // Do any additional setup after loading the view.
        //add .png to titles of all title values
//        for i in 0...titlesArray.count {
//            titlesArray[i] += ".png"
//        }
//        for i in 0...urlsArray.count {
//            
//        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return urlsArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath as IndexPath)
    
        // Configure the cell
        let imageUrl = NSURL(string: "\(urlsArray[1])")
        //error with line below, "value of type uicollectionviewcell has no member imageView"
        cell.imageView.kf_setImageWithURL(imageUrl!)
            
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
