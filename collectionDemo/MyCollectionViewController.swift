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
//struct ImageCell: Decodable {
//    let title: String
//    let imageUrl: String
//    let subreddit: String
//
//    init(json: [String:AnyObject]) {
//        title = json["title"] as? String ?? ""
//        imageUrl = json["url"] as? String ?? ""
//        subreddit = json["subreddit"] as? String ?? ""
//    }
//}
private let reuseIdentifier = "MyCell"

class MyCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet var myCollectionView: UICollectionView!
    
//    let queue = DispatchQueue(label: "MyDispatchQueueLabel")
    
    
    //MARK: Private Variables
    
    var titlesArray = [String]()
    var urlsArray = [String]()

    
    //MARK: Private Functions
    /*
     Sometimes urls doesn't end with an image extension, leaving image blanked when setting it as a view.
     Solution is to use inout which is basically pass by reference. We pass urlsArray into function, and allows us to look at
     urls as variables instead of constants
     */
    func addExtensionToUrls(urls: inout [String]){
        for i in 0...24 {
            if !(urls[i].contains(".jpg") || urls[i].contains(".png")) {
                urls[i].append(contentsOf: ".jpg")
            }
//            print(urls[i])
        }
    }

    
    //Function to return json of given subreddit, parse for urls, and add urls to Array of Strings
    func getHttpRequest(UrlStringOfSubreddit: String, completion: @escaping (Bool, Any?, Error?)->Void){
        
//        var titlesArray = [String]()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
        var urls = [String]()
        guard let url = URL(string: UrlStringOfSubreddit) else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error == nil {
                if let data = data {
                    let json: [String:AnyObject]!
                    do
                    {
                        json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String:AnyObject]
                    }
                    catch
                    {
                        return
                    }
                    
                    if let dataDic = json["data"] as? [String:AnyObject],
                        let dataArray = dataDic["children"] as? [[String:AnyObject]]{
                        for i in 0...24{
                            let url = dataArray[i]["data"]!["url"]! as! String
//                            let title = dataArray[index]["data"]!["title"]! as! String
                            urls.append(url)
//                            self.titlesArray.append(title)
                        }
                        completion(true, urls, nil)
//                        print(self.titlesArray)
                }
            }
        }
    }
        task.resume()
    }
        
}

    
    override func viewDidLoad() {
        super.viewDidLoad()
//        configure images to be stored in a urlcache
        let memoryCapacity = 500 * 1024 * 1024
        let diskCapacity = 500 * 1024 * 1024
        let urlCache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: nil)
        URLCache.shared = urlCache
        
//      self.collectionView?.delegate = self ; dont need since we did it in storyboard.
        let UrlStringOfSubreddit = "https://reddit.com/r/earthPorn/.json?count=25"
            self.getHttpRequest(UrlStringOfSubreddit: UrlStringOfSubreddit) { (success, response, error) in
            if success {
                guard let urls = response as? [String] else {return}
                self.urlsArray = urls
                self.addExtensionToUrls(urls: &self.urlsArray)
                print("\n")
            } else if let error = error {
                print("Http request error: ", error)
            }
            
                DispatchQueue.main.async {
                    print(self.urlsArray)
                    self.myCollectionView.reloadData()
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! MyCollectionViewCell
        
        let resource = ImageResource(downloadURL: URL(string: urlsArray[indexPath.row])!, cacheKey: urlsArray[indexPath.row])
        cell.imageView.kf.indicatorType = .activity
        cell.imageView.kf.setImage(with: resource)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = view.frame.width
        let widthPerItem = (availableWidth) / 3
        return CGSize(width: widthPerItem-2.5, height: widthPerItem-2.5)
    }

}
