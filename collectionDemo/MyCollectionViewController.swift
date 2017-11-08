//
//  MyCollectionViewController.swift
//  collectionDemo
//
//  Created by minh ho on 9/27/17.
//  Copyright © 2017 minh ho. All rights reserved.
//

import UIKit
import Foundation
import SDWebImage

//NOTES: for images not showing up cuz adding extension doesnt work, need scraping etc, just delete from array before putting in collectionview
private let reuseIdentifier = "MyCell"

class MyCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet var myCollectionView: UICollectionView!
    var subRedditString = String()
    @IBAction func goBackToSearch(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: Private Variables
    
    var titlesArray = [String]()
    var urlsArray = [String]()
    var urlsThumbnail = [String]()
    //MARK: Private Functions
    
    func dismissFullScreenImage(_ sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }
    
    /*
     Sometimes urls doesn't end with an image extension, leaving image blanked when setting it as a view.
     Solution is to use inout which is basically pass by reference. We pass urlsArray into function, and allows us to look at
     urls as variables instead of constants
     */
    func addExtensionToUrls(urls: inout [String]){
//        print(urls.count)
//        print("\n")
        for i in 0..<urls.count {
            if !(urls[i].contains(".jpg") || urls[i].contains(".png")) {
                urls[i].append(contentsOf: ".jpg")
            }
        }
    }
    //Function to count number of flickr urls and other unwanted urls.
    func countFlickrUrls(urls: inout [String]) -> Int{
        var c:Int = 0
        for i in 0..<urls.count {
            if ((urls[i].contains("flickr.com") || (urls[i].contains("gfycat")) || (urls[i].contains("/.jpg")) || (urls[i].contains("gif")) || (urls[i].contains("/a/")))){
                c += 1
            }
        }
        return c
    }
    //Function to remove flickr images from array so they dont come up empty in view
    
    func removeFlickrUrls(urls: inout [String], newCount: Int){
        for i in 0..<newCount {
            if ((urls[i].contains("flickr.com") || (urls[i].contains("gfycat")) || (urls[i].contains("/.jpg")) || (urls[i].contains("gif")) || (urls[i].contains("/a/")))) {
                urls.remove(at: i)
            }
        }
    }
    //Fuction to swipe left from edge and go backwards from collectionView to UIText
    func swipeFromEdge(recognizer: UIScreenEdgePanGestureRecognizer) {
        self.performSegue(withIdentifier: "SegueCollectionBack", sender: self)
    }

    
    //Function to return json of given subreddit, parse for urls, and add urls to Array of Strings
    func getHttpRequest(UrlStringOfSubreddit: String, completion: @escaping (Bool, Any?, Error?)->Void){
        
//        var titlesArray = [String]()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
        var urls = [String]()
//        var urlsThumbnail = [String]()
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
                        for i in 0...49{
                            let url = dataArray[i]["data"]!["url"]! as! String
//                            let title = dataArray[index]["data"]!["title"]! as! String
                            let thumbnail_url = dataArray[i]["data"]!["thumbnail"]! as! String
                            self.urlsThumbnail.append(thumbnail_url)
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
        let recognizer: UIScreenEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector((swipeFromEdge)))
        recognizer.edges = .left
        recognizer.edges = .right
        view.addGestureRecognizer(recognizer)
//        let memoryCapacity = 500 * 1024 * 1024
//        let diskCapacity = 500 * 1024 * 1024
//        let urlCache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: nil)
//        URLCache.shared = urlCache
//      self.collectionView?.delegate = self
        //get rid of spaces at end, usually adds space on iphone after autocompletingr a word.
        let subRedditString_new = subRedditString.replacingOccurrences(of: " ", with: "")
        let UrlStringOfSubreddit = "https://reddit.com/r/" + subRedditString_new + "/.json?limit=50"
            self.getHttpRequest(UrlStringOfSubreddit: UrlStringOfSubreddit) { (success, response, error) in
            if success {
                guard let urls = response as? [String] else {return}
                self.urlsArray = urls
                print(self.urlsThumbnail.count)
                print("\n")
                print(self.urlsArray.count)
                self.addExtensionToUrls(urls: &self.urlsArray)
//                let newCount = self.urlsArray.count - self.countFlickrUrls(urls: &self.urlsArray)
//                self.removeFlickrUrls(urls: &self.urlsArray, newCount: newCount)
                print("\n")
                print(self.urlsArray.count)
            } else if let error = error {
                print("Http request error: ", error)
            }
            
                DispatchQueue.main.async {
//                    print(self.urlsArray)
                    self.myCollectionView.reloadData()
                }
            }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        print("OMG YOU GOT MEMORY ERRORS WTF")
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
        return urlsThumbnail.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! MyCollectionViewCell
        
//        let resource = ImageResource(downloadURL: URL(string: urlsArray[indexPath.row])!, cacheKey: urlsArray[indexPath.row])
        //add second parameter specifying placeholder picture
//        cell.imageView.sd_setImage(with: URL(string: urlsArray[indexPath.row]) )
//        cell.imageView.sd_setImage(with: URL(string: urlsThumbnail[indexPath.row]) )
        cell.imageView.sd_setShowActivityIndicatorView(true)
        cell.imageView.sd_setIndicatorStyle(.gray)
        cell.imageView.sd_setImage(with: URL(string: urlsThumbnail[indexPath.row]), placeholderImage: UIImage(named: "Placeholder.png"))
        
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fullScreenImage: UIImageView
        fullScreenImage = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        fullScreenImage.sd_setShowActivityIndicatorView(true)
        fullScreenImage.sd_setIndicatorStyle(.gray)
        
        fullScreenImage.sd_setImage(with: URL(string: urlsArray[indexPath.row]), placeholderImage: UIImage(named: "Placeholder.png"))
        fullScreenImage.backgroundColor = .black
        fullScreenImage.contentMode = .scaleAspectFit
        fullScreenImage.isUserInteractionEnabled = true
        
        let tap = UIPanGestureRecognizer(target: self, action: #selector(dismissFullScreenImage))
        fullScreenImage.addGestureRecognizer(tap)
        self.view.addSubview(fullScreenImage)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = view.frame.width
        let widthPerItem = (availableWidth) / 3
        return CGSize(width: widthPerItem-2.5, height: widthPerItem-2.5)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }

}
