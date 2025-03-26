//
//  CountryDetailsView.swift
//  Countries
//
//  Created by Salma Alkashir on 24/03/2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct CountryDetailsView: View {
  let country: CountryModel
  
  let fullWidth = UIScreen.main.bounds.width
  let fullHeight = UIScreen.main.bounds.height
  
  var onAddCountry: ((CountryModel) -> Void)?
  var showToast: ((String) -> Void)?
  
  var body: some View {
    ZStack {
      VStack {
        WebImage(url: URL(string: country.flags?.png ?? ""))
          .resizable()
          .scaledToFill()
          .frame(width: fullWidth - 20 , height: fullHeight * 0.25, alignment: .center)
          .clipShape(RoundedRectangle(cornerRadius: 10))
          .shadow(radius: 3)

        HStack {
          Text("City: \(country.name ?? "")" + ",")
            .frame(maxWidth: fullWidth - 20, maxHeight: .infinity)
            .font(.system(size: 20, weight: .bold))
        
          Text("Capital: \(country.capital ?? "")")
            .frame(maxWidth: fullWidth - 20, maxHeight: .infinity)
            .font(.system(size: 20, weight: .semibold))
        }.frame(width: fullWidth - 20, height: 100, alignment: .topLeading)
          .background(Color.white)
          .cornerRadius(10)
          .shadow(radius: 3)
        HStack {
          Text ("Currency: \(country.currencies?[0].code ?? "")")
            .frame(maxWidth: fullWidth - 20, maxHeight: 100)
            .font(.system(size: 20, weight: .semibold))
        }  .background(Color.white)
          .cornerRadius(10)
          .shadow(radius: 3)
        
        HStack {
          Text ("Population: \(country.population ?? 0)  people")
            .frame(maxWidth: fullWidth - 20, maxHeight: 100)
            .font(.system(size: 20, weight: .semibold))
        }.background(Color.white)
          .cornerRadius(10)
          .shadow(radius: 3)
        HStack {
          Text ("Region: \(country.region ?? "")")
            .frame(maxWidth: fullWidth - 20, maxHeight: 100)
            .font(.system(size: 20, weight: .semibold))
        }.background(Color.white)
          .cornerRadius(10)
          .shadow(radius: 3)
      }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
   Button(action: {
         onAddCountry?(country)
         if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first {
           Helpers.showToastMessage(
            in: window,
            message: "Added Country To Home",
            color: .blue,
            x: (window.bounds.size.width - 280) / 2,
            y: window.bounds.size.height - 140 - 30,
            labelHeight: 50,
            labelWidth: 280,
            textColor: .white
           )
         }
   }) {
     Image("addToHomeIcon")
       .resizable()
       .frame(width: 30, height: 30, alignment: .trailing)
       .padding()
       .background(Circle().fill(Color.black))
       .foregroundColor(.white)
   }
  }
  
}

