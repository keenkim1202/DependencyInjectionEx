//
//  DICaller.swift
//  DIKit
//
//  Created by KEEN on 2022/05/10.
//

import Foundation

public class DICaller {
  
  public static let shared = DICaller()
  
  private init() {}
  
  public func fetchRandomNames(completion: @escaping ([String]) -> Void) {
    guard let url = URL(string: "http://names.drycodes.com/10") else {
      completion([])
      return
    }
    
    let task = URLSession.shared.dataTask(with: url) { data, _, error in
      guard let data = data, error == nil else {
        completion([])
        return
      }
      
      do {
        guard let names = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String] else {
          completion([])
          return
        }
        
        completion(names)
      } catch {
        completion([])
      }
    }
    task.resume()
  }
  
}
