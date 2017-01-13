# InstaViewer
This is a simple mock/practice app for viewing specific user's Instagram photos/videos. I will regularly update this app for a better mock the native iOS Instagram app.

I am currently using a public API: https://www.instagram.com/$USERNAME$/media/?&max_id=$LAST_ID$

### Features
InstaViewer can currently support:
  - auth-free viewing

### Third-party libraries
InstaViewer uses a number of open source projects to work properly:

* [Alamofire] - an HTTP networking library written in Swift.
* [AlamofireImage] - an image component library for Alamofire.
* [SwiftyJSON] - SwiftyJSON makes it easy to deal with JSON data in Swift.
* [Chameleon] - a lightweight, yet powerful, color framework for iOS.
* [Realm] - Realm is a mobile database that runs directly inside phones.

### Todos
- Implement MVP design for lighter-weight ViewControllers
- UI tweaking
- Video players
- Custom image downloader cache options
- Write more tests




   [Alamofire]: <https://github.com/Alamofire/Alamofire>
   [AlamofireImage]: <https://github.com/Alamofire/AlamofireImage>
   [SwiftyJSON]: <https://github.com/SwiftyJSON/SwiftyJSON>
   [Chameleon]: <https://github.com/ViccAlexander/Chameleon>
   [Realm]: <https://github.com/realm/realm-cocoa>
