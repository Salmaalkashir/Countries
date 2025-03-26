//
//  CoreDataManager.swift
//  Countries
//
//  Created by Salma Alkashir on 25/03/2025.
//

import CoreData
import UIKit

protocol CoreDataManagerProtocol {
  func SaveCountryCoreData(country: CountryModel)
  func fetchCountries() -> [NSManagedObject]
}


final class CoreDataManager: CoreDataManagerProtocol {
  
  typealias DataType = NSManagedObject
  
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  let managedContext: NSManagedObjectContext!
  let entity: NSEntityDescription!
  
  private static var coreData: CoreDataManager?
  
  public static func getObj () -> CoreDataManager {
    if let obj = coreData{
      return obj
    }else
    {
      coreData = CoreDataManager()
      return coreData!
    }
  }
  
  private init() {
    managedContext = appDelegate.persistentContainer.viewContext
    entity = NSEntityDescription.entity(forEntityName: "CoreData", in: managedContext)
  }
  
  //MARK: - Save Countries
  func SaveCountryCoreData(country: CountryModel) {
    let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Countries")
    fetchRequest.predicate = NSPredicate(format: "name == %@", country.name ?? "")
    
    do {
      let results = try managedContext.fetch(fetchRequest)
      
      if results.isEmpty {
        let countries = NSEntityDescription.insertNewObject(forEntityName: "Countries", into: managedContext)
        
        countries.setValue(country.name, forKey: "name")
        countries.setValue(country.capital, forKey: "capital")
        countries.setValue(country.currencies?.first?.code, forKey: "currency")
        countries.setValue(country.alpha2Code, forKey: "alpha2Code")
        do {
          try self.managedContext.save()
          print("Saved country to CoreData")
        } catch {
          print("Failed to save country to CoreData: \(error)")
        }
      } else {
        print("Country already exists in CoreData")
      }
    } catch {
      print("Failed to fetch country from CoreData: \(error)")
    }
  }
  
  //MARK: - Retrieve Countries
  func fetchCountries() -> [NSManagedObject] {
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Countries")
    do {
      let retrievedArray = try managedContext.fetch(fetchRequest)
      if retrievedArray.count > 0 {
        return retrievedArray
      } else {
        print("No Countries found in CoreData")
        return []
      }
    } catch {
      print("Failed to fetch Countries from CoreData: \(error)")
      return []
    }
  }
}
