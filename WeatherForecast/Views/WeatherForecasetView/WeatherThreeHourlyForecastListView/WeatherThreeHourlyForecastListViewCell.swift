//
//  WeatherThreeHourlyForecastListViewCell.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/4/23.
//

import SwiftUI

struct WeatherThreeHourlyForecastListViewCell: View {
    @AppStorage(AppStorageKeys.tempScale) var tempScale: TempScale = .fahrenheit
    var forecast: Forecast
    var isFirst: Bool
    
    var body: some View {
        VStack {
            Text(isFirst ? "Now" : forecast.dateTime.unixTimeToDateStr(dateFormat: Constants.dateFormat).getDateStrinng(dateFormat: Constants.dateFormat, newDateFormat: "ha"))
            if let weather = forecast.weather.first {
                WeatherImageView(icon: weather.icon, width: 40)
            }
            Text("\(forecast.temp.getDegree(tempScale: tempScale).formatDouble(maxFractions: 0).appendDegree())")
        }
        .fontWeight(.bold)
    }
}

#Preview {
    WeatherThreeHourlyForecastListViewCell(forecast: PreviewManager.oneCallResponse.current,
                                           isFirst: false
    )
        .environmentObject(LocalFileManager())
        .preferredColorScheme(.dark)
}
