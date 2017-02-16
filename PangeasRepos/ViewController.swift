//
//  ViewController.swift
//  PangeasRepos
//
//  Created by Ronald Hernandez on 2/2/17.
//  Copyright © 2017 Ronaldoh1. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    private let cellIdentifier = "cell"

    private var dataArray = [Repo]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)

        downloadData()
    }

    //MARK: Download Data

    private func downloadData() {

        let configuration = URLSessionConfiguration.default
        let url = URL(string: "https://api.github.com/orgs/gopangea/repos")
        let sesssion = URLSession(configuration: configuration)

        sesssion.dataTask(with: url!) { (data, response, error) in

            guard error == nil else {
                print(error.debugDescription)
                return
            }

            guard let data = data else {
                print(error.debugDescription)
                return
            }

            do {

                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyObject]  {

                    for dictionary in json {
                        let temp = dictionary["owner"] as? [String : AnyObject]
                        let imageURL = temp?["avatar_url"] as? String
                        let name = dictionary["name"] as? String
                        let count = dictionary["stargazers_count"] as? Int
                        let language = dictionary["language"] as? String

                        let imageSession = URLSession(configuration: .default)

                        imageSession.dataTask(with: URL(string:imageURL!)!) { (data, response, error) in

                            let repo = Repo(avatarURL: UIImage(data: data!) , name: name, starCount: count, language: language)
                            self.dataArray.append(repo)

                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }.resume()

                    }
                }

            } catch let error {
                print(error)
            }

            }.resume()



    }


    //MARK: UITableViewDataSource Methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        let repo = dataArray[indexPath.row]
        if let name = repo.name, let starCount = repo.starCount, let image = repo.avatarURL {
            
            cell.textLabel?.text = name
            cell.detailTextLabel?.text = "It has been stared \(starCount)"
            cell.imageView?.image = image
        }
        
        return cell
    }
    
}

