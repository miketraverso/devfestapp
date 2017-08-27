# DevFest Florida App

A Flutter based conference app built for DevFest Florida, backed by Firebase 🔥

## Getting Started with Flutter

For help getting started with Flutter, check out their online [documentation](http://flutter.io/).

It is recommended that you use IntelliJ IDEA for this. Please refer to the [documentation](http://flutter.io/) on how to setup your IDE.

## Getting Started with this code

Open the project in IntelliJ IDEA. You'll notice that there is lib directory. All the code for this project lives in this directory. `ios` directory holds your iOS project and `android` holds your Android project. Opening the projects in those directories in Xcode or Android Studio, respectivefully will allow you to modify those projects as you would if they were regularly created projects of their respective nature.

Heading back to our `lib` directory, you'll see a file named `main.dart`. Here is where you can change a lot of information to meet the needs of your app. 

![Todos to customize your app](https://github.com/miketraverso/devfest_florida_app/blob/master/ConFlutter%20TODOs.png "TODOs")

For example, change the color, the logo, a custom font for the nav bar, the location specifics, the Firebase root node where your data can be found, and more. Use the JSON file in the root directory as an exampe of how you can set up your data in a Firebase database. PLEASE make sure that you replace your Firebase config in the iOS & Android projects per the Firebase instructions. If you do NOT change this you'll be pulling back our data.

## Building

Be sure to up your version numbers appropriately. For iOS please refer to the [iOS build instructions](https://flutter.io/ios-release/). Do NOT forget to run `flutter build ios` first when trying to archive and upload your app to iTunes Connect. For Android please refer to the [Android build instructions](https://flutter.io/android-release/).

## Our app to give you an example

Ours is a single day conference. If yours is multiple days you'll notice more day tabs at the top. Users will be able to swipe across or tap a tab and switch to the schedule for that day.

![Example of app with some dummy data](https://github.com/miketraverso/devfest_florida_app/blob/master/output.gif "Example")

## To-Do
- [ ] something else that's ridiculous awesome but I'm not telling so go buy a ticket to [devfestflorida.org](https://devfestflorida.org) and find out :)
