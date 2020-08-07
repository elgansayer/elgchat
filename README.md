<p align="center">
  <a href="https://flutter.io/">
  </a>

  <h3 align="center">ElgChat</h3>

  <p align="center">
    A better Flutter chat UI. With chat list, conversation screen and a find user screen. It can be expected to support all chat features you would find in a modern chat like WhatsApp or FaceBook messenger. A backend system is up to you while an example provides a complete font and backend working system.
    <br>
    This project aims to make implementing a chat system a bit quicker while still being very customizable. This chat system is developed to be actively used in one of my own applications and an additional goal is to provide a fully working example using firestore and firebase functions.
  </p>
</p>

## Table of contents

- [Quick start](#quick-start)
- [Example Setup](#example-setup)
- [Firstore Example](#firebase-example)
- [Firebase Functions Example](#firebase-functions-example)
- [Other Examples](#other-examples)
- [Features](#features)
- [Creators](#authors)
- [Copyright and license](#license)


## Features
# Conversation Screen
This screen is for displaying a conversation with a group or indivdual.
* Generic extendable model
* Overrideable state class allowing extended extension of look and behaviour
* Overrideable logic class allowing extended extension of behaviour
* AppBar Searchable conversation list
* Scrollbar actions / scroll to bottom
* Supports selecting messages
* Supports starring messages
* Supports quoting/replying to messages
* Supports deleting messages
* Supports copying messages to clipboard
* Supports inserting smileys
* Supports tap messages to react
* Support expanding typing area
* Support insert media callbacks
* Support stylish bubbles
* Support parsed hyper text
* Support swipe to reply
* Support app bar actions
* Support read receipt
* Support insert location pins
* Callbacks on actions
* Split logic class without using dependencies

# Chat List
This screen is for displaying and selecting chats from a list of groups of individuals.

* Generic extendable model
* Overrideable state class allowing extended extension of look and behaviour
* Overrideable logic class allowing extended extension of behaviour
* AppBar Searchable chat list
* Supports selecting chats
* Supports select all chats
* Supports pinning
* Supports archiving chats
* Supports deleting chats
* Supports muting chats
* Supports mark unread
* Callbacks on list actions
* Split logic class without using dependencies

# Find User Screen
This screen is meant for starting a new chat and simply provides a search callback to populate a list.

* Generic extendable model
* Overrideable state class allowing extended extension of look and behaviour
* Overrideable logic class allowing extended extension of behaviour
* AppBar Searchable
* Supports selecting conatcts
* Callbacks on list actions
* Split logic class without using dependencies

## QUick Start


1. Depend on it
Add this to your package's pubspec.yaml file:

```dependencies:
  elgchat: ^1.0.0
```

2. Install it
You can install packages from the command line:

with Flutter:

```$ flutter pub get```

Alternatively, your editor might support flutter pub get. Check the docs for your editor to learn more.

3. Import it
Now in your Dart code, you can use:

```import 'elgchat/elgchat.dart';```


## Versioning

For the versions available, see the [tags on this repository](https://github.com/elgansayer/elgchat/tags).

## Authors

* **Elgan Sayer** - *Initial work*
See also the list of [contributors](https://github.com/elgansayer/elgchat/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

* Feature aims
x Complete example with firebase
x Conversation groups tested
x More animations

## Acknowledgments
