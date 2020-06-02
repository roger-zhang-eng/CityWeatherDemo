# CityWeatherDemo 

`CityWeatherDemo` is one demo programm, running on iOS platform.



## Demo	Video
https://youtu.be/tFZAajnE36w

## Requirements
- Xcode 11.3.1
- iOS 12.0+
- Swift 5.1
- Cocoapod 1.8.4

## Installation Steps
- Open CityWeatherDemo.xcworkspace by Xcode. 
(If project is not complete after opening by Xcode, please run 'pod install')

## Highlight functions
- The latest city weather info and Search records will be stored in app permanently. Next app launch, the last city weather info is displayed first without network api call.
- Network connection state is monitored. If one search is failed by disconnected network, once network recovery, last failed search will be auto triggered to get weather info.
- GPS locating is supported to get current location weather info.
- Current displayed city weather info could be refreshed by clicking refresh button.

## Screens description
- Search City View: 
  Nav bar left button is for recent search list. Nav Right refresh button is for refreshing current displayed city weather data. Nav right gps location button is for locating device position for search weather info. Country flag and code text could be displayed, and the filter button is for change country (preferred country codes are listed on top). Search bar is for city name or zip code input. Until clicking search button in keyboard, the search context will be used to search weather info.
- Recent Search List: 
  List all search history, that is sorted by most recent search. User could delete multiple records by clicking edit button, and user could check the recorded location item's current weather by tap the item.

## Unit Test
- WeatherDataServiceTest: It tests backend service data downloading and parsing, by network api call.
- SearchCityWeatherViewModelTest: By RxTest, it tests search city viewModel with mock services.
- RecentSearchViewModelTest: By RxTest, it tests recent search viewMode.

## SW architecture, configuration and source code
RxSwift MVVM design pattern, and Swift 5.1 source code with CocoaPods support

- Views folder is for 2x screens VC and customised Cell views.
- ViewModels folder is for viewModule without UI components.
- DataModels folder is for web service, location manager, network monitor and data decode.
- Utilities folder is tool class, including Extensions.
- Support folder is for assets and city list json file.
- CityWeatherDemoTests folder is for Unit Test.
- Backend service 'openWeathermap' AppId is configured in Info.plist - key 'AppID'
- Preference country codes are configured in Info.plist - key 'PreferenceCountryCodes' 

## Requirement implementation
- In order to support city search from different countries, cities json file is stored in app. CityWeatherHelper supports to decode in DispatchQueue (time consuming around 3s), not blocking UI. Once decoding done, it will post notification loadCitiesJSON to let user have chance to change country. 
- App choose city name search by text content, and app choose zip code search by digital number content. (Note: Web service do not support UK letter post code.)
- Search by GPS is supported by CoreLocation. 
- Only the latest city weather data is saved in UserDefaults. Every time app launch, it will auto load this offline weather info to display.
- Recent search records are saved in UserDefaults. User could select one to check this location's current weather.
- User could delete one or more recorded search locations by selecting 'Edit' button.


