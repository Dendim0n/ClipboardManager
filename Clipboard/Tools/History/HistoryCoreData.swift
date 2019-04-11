//
//  HistoryCoreData.swift
//  Clipboard
//
//  Created by 任岐鸣 on 2019/4/1.
//  Copyright © 2019 Qiming. All rights reserved.
//

import AppKit

class HistoryCoreData {
    
    static let shared = HistoryCoreData()
    init() {
        
    }
    
    func addToDB(content:HistoryContent) {
//        delIfExists(content: content)
//        threadSafeDB { (db) in
//            try? db.executeUpdate("insert into `History`(`type`,`data`,`string`,`source`,`icon`) values(?, ?, ?, ?, ?);", values: [content.contentType, content.data, content.string, content.sourceApp, content.iconData()])
//        }
    }
    func removeFirst() {
//        threadSafeDB { (db) in
//            if let result = try? db.executeQuery("SELECT * FROM History", values: nil) {
//                result.next()
//                let content = HistoryContent(contentType: Int(result.int(forColumn: "type")),
//                                             data: result.data(forColumn: "data"),
//                                             string: result.string(forColumn: "string"),
//                                             iconData: result.data(forColumn: "icon"),
//                                             sourceApp: result.string(forColumn: "source"))
//                try? db.executeUpdate("delete FROM History where data=? and string=?", values: [content.data, content.string])
//            }
//        }
    }
    func delIfExists(content:HistoryContent) {
//        threadSafeDB { (db) in
//            if let data = content.data {
//                try? db.executeUpdate("delete FROM History where data=?", values: [data])
//            } else if let str = content.string {
//                try? db.executeUpdate("delete FROM History where string=?", values: [str])
//            }
//        }
    }
    func readFromCoreData() {
//        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else { return }
//
//        //We need to create a context from this container
//        let managedContext = appDelegate.persistentContainer.viewContext
//
//        let fetchRequest = ClipHistory.fetchRequest
//
//        var res = [HistoryContent]()
//        do {
//            let result fetchRequest
//            for data in result as! [ClipHistory] {
////                print(data)
//                let content = HistoryContent(contentType:data.type,
//                                             data: data.data,
//                                             string: data.string,
//                                             iconData: data.icon,
//                                             sourceApp: data.source)
//                res.append(content)
//            }
//
//        } catch {
//            print("Failed")
//        }
//        History.shared.contentStorage = res.reversed()
//        print("db loaded.")
//        if let vc = MainApplication.shared.popoverClip.contentViewController as? ClipboardContentViewController {
//            DispatchQueue.main.async {
//                vc.loading = false
//                vc.emptyPrompt.stringValue = "无历史记录"
//                vc.emptyPrompt.alphaValue = 0.5
//                vc.refresh()
//            }
//        }
//        DispatchQueue.global().async {
//            if let vc = MainApplication.shared.popoverClip.contentViewController as? ClipboardContentViewController {
//                DispatchQueue.main.async {
//                    vc.loading = false
//                    if History.shared.contentStorage.count == 0 {
//                        vc.emptyPrompt.stringValue = "无历史记录"
//                        vc.emptyPrompt.alphaValue = 0.5
//                    }
//                    vc.refresh()
//                }
//            }
//        }
    }
    func removeAll() {
//        threadSafeDB { (db) in
//            try? db.executeUpdate("DROP TABLE `History`", values: nil)
//            try? db.executeUpdate("CREATE TABLE IF NOT EXISTS `History` (`type` INTEGER,`data`    BLOB,`string` TEXT,`source` TEXT,`icon` BLOB);", values: nil)
//            try? db.executeUpdate("VACUUM;", values: nil)
//        }
    }
    
    
    
//    func createData(){
//        //As we know that container is set up in the AppDelegates so we need to refer that container.
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//
//        //We need to create a context from this container
//        let managedContext = appDelegate.persistentContainer.viewContext
//
//        //Now let’s create an entity and new user records.
//        let userEntity = NSEntityDescription.entity(forEntityName: "User", in: managedContext)!
//
//        //final, we need to add some data to our newly created record for each keys using
//        //here adding 5 data with loop
//
//        for i in 1...5 {
//
//            let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
//            user.setValue("Ankur\(i)", forKeyPath: "username")
//            user.setValue("ankur\(i)@test.com", forKey: "email")
//            user.setValue("ankur\(i)", forKey: "password")
//        }
//
//        //Now we have set all the values. The next step is to save them inside the Core Data
//
//        do {
//            try managedContext.save()
//
//        } catch let error as NSError {
//            print("Could not save. \(error), \(error.userInfo)")
//        }
//    }
    
    func retrieveData() {
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "History")
        
        //        fetchRequest.fetchLimit = 1
        //        fetchRequest.predicate = NSPredicate(format: "username = %@", "Ankur")
        //        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "email", ascending: false)]
        //
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [History] {
//                print(data.value(forKey: "username") as! String)
                print(data)
            }
            
        } catch {
            print("Failed")
        }
    }
    
    func updateData(){
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "username = %@", "Ankur1")
        do
        {
            let test = try managedContext.fetch(fetchRequest)
            
            let objectUpdate = test[0] as! NSManagedObject
            objectUpdate.setValue("newName", forKey: "username")
            objectUpdate.setValue("newmail", forKey: "email")
            objectUpdate.setValue("newpassword", forKey: "password")
            do{
                try managedContext.save()
            }
            catch
            {
                print(error)
            }
        }
        catch
        {
            print(error)
        }
        
    }
    
    func deleteData(){
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "username = %@", "Ankur3")
        
        do
        {
            let test = try managedContext.fetch(fetchRequest)
            
            let objectToDelete = test[0] as! NSManagedObject
            managedContext.delete(objectToDelete)
            
            do{
                try managedContext.save()
            }
            catch
            {
                print(error)
            }
            
        }
        catch
        {
            print(error)
        }
    }
}
