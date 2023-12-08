//
//  LocationsView.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/5/23.
//

import SwiftUI

struct LocationsView: View {
    @EnvironmentObject private var coordinator: MainCoordinator
    @StateObject var vm: LocationForecastViewModel = LocationForecastViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dismissSearch) private var dismissSearch
    @AppStorage(AppStorageKeys.tempScale) private var tempScale: TempScale = .fahrenheit
    @State var searchBarPresented = false
    var onDismiss: ((City?) -> Void)?
    
    var body: some View {
        NavigationStack {
            VStack {
                if vm.searchText.isEmpty {
                    locationList()
                } else {
                    locationSearchResult()
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 15, height: 15)
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        ForEach(TempScale.allCases) { scale in
                            Button(action: {
                                tempScale = scale
                            }, label: {
                                tempScaleOptionBtn(selected: tempScale, option: scale)
                            })
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle("Weather")
            .searchable(text: $vm.searchText, placement: .navigationBarDrawer(displayMode: .always))
            .navigationBarBackButtonHidden(true)
        }
        .sheet(isPresented: $coordinator.weatherForecastSheetPresented) {
            WeatherForecastView(
                city: coordinator.city,
                showTopActionBar: true) {
                    DispatchQueue.main.async {
                        self.vm.searchText = ""
                        self.dismissSearch()
                    }
                }
        }
    }
}

extension LocationsView {
    @ViewBuilder
    func locationSearchResult() -> some View {
        if vm.isLoading {
            VStack {
                ProgressView("Loading...")
            }
        } else {
            VStack {
                LocationSearchResultListView(predictions: vm.predictions) { prediction in
                    dismissSearch()
                    UIApplication.shared.hideKeyboard()

                    Task {
                        if let details = await vm.getPlaceDetails(placeId: prediction.placeId) {
                            self.coordinator.showForecastSheet(city: City(id: 0, 
                                                                          population: 0,
                                                                          timezone: 0,
                                                                          coordinate: CityCoordinate(lat: details.geometry.location.latitude, lon: details.geometry.location.longitude),
                                                                          name: details.formattedAddress,
                                                                          country: "",
                                                                          sunrise: 0,
                                                                          sunset: 0))
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func locationList() -> some View {
        LocationListView() { city in
            if let onDismiss {
                onDismiss(city)
                dismiss()
            }
        }
    }
}

extension LocationsView {
    @ViewBuilder
    func tempScaleOptionBtn(selected: TempScale, option: TempScale) -> some View {
        HStack {
            if selected != option {
                Spacer()
                    .frame(width: 10)
            } else {
                Image(systemName: "checkmark")
                    .resizable()
                    .frame(width: 10, height: 10)
            }
            Text(option.rawValue)
            Spacer()
            Text("&deg;\(option.rawValue.first?.uppercased() ?? "")")
        }
    }
}

#Preview {
    LocationsView()
        .environmentObject(LocationManager())
        .environmentObject(MainCoordinator())
}