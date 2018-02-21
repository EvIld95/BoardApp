//
//  RealmManager.swift
//  BoardApp
//
//  Created by Paweł Szudrowicz on 21.02.2018.
//  Copyright © 2018 Paweł Szudrowicz. All rights reserved.
//


import Foundation
import RealmSwift
import MBProgressHUD

class RealmManager {
    static let sharedInstance = RealmManager()
    var realm : Realm?
    var realmPublic: Realm?
    var currentLoggedUser: SyncUser?
    private let serverAddress = "http://52.166.88.154:9080"
    
    func connectToRealmDatabase(username:String, password: String, register: Bool, viewControllerHandler: UIViewController!, completion: @escaping (_ user: SyncUser) -> ()) {
        SyncUser.logIn(with: .usernamePassword(username: username, password: password, register: register), server: URL(string: serverAddress)!) { user, error in
            
            guard let user = user else {
                print(error?.localizedDescription as Any)
                let alertController = UIAlertController(title: "Error!", message: "Problem with connection to database server", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                viewControllerHandler.present(alertController, animated: true, completion: nil)
                return
            }
            
            DispatchQueue.main.async {
                let configuration = Realm.Configuration(
                    syncConfiguration: SyncConfiguration(user: user, realmURL: URL(string: "realm://52.166.88.154:9080/~/boardapp")!)
                )
                
                self.realm = try! Realm(configuration: configuration)
                self.connectToRealmPublicDatabase(viewControllerHandler: viewControllerHandler, mainUser: user, completion: completion)
            }
        }
    }
    
    private func connectToRealmPublicDatabase(viewControllerHandler: UIViewController!, mainUser: SyncUser, completion: @escaping (_ syncMainUser: SyncUser) -> ()) {
        SyncUser.logIn(with: .usernamePassword(username: "pablo@gmail.com", password: "qwerty", register: false), server: URL(string: serverAddress)!) { user, error in
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: viewControllerHandler.view, animated: true)
            }
            guard let user = user else {
                let alertController = UIAlertController(title: "Error!", message: error!.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                viewControllerHandler.present(alertController, animated: true, completion: nil)
                return
            }
            self.currentLoggedUser = mainUser
            
            DispatchQueue.main.async {
                let configurationPublic = Realm.Configuration(
                    syncConfiguration: SyncConfiguration(user: user, realmURL: URL(string: "realm://52.166.88.154:9080/globalDatabase")!)
                )
                self.realmPublic = try! Realm(configuration: configurationPublic)
                completion(mainUser)
            }
        }
    }
    
    func logoutAllUsers() {
        for user in SyncUser.all {
            user.value.logOut()
        }
    }
}

