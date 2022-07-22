//
//  AuthContentView.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/20/22.
//

import SwiftUI

struct AuthContentView: View {
    var body: some View {
        Button("API Req") {
//            URLSession(configuration: .default)
            let task = URLSession(configuration: .default).dataTask(with: URL(string: "https://sakai.duke.edu/direct/content/site/a331dab2-2789-40f2-bf4e-96720371ac97.json")!) { data, response, error in
                print(data)
                print(response)
                print(error)
                
                let fullJson = try! JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String: AnyObject]
                print(fullJson)
            }
            task.resume()
        }
    }
}

struct AuthContentView_Previews: PreviewProvider {
    static var previews: some View {
        AuthContentView()
    }
}
