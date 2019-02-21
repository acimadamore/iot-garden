# IoT Garden

Watering System made with an Arduino Board that comunicates events and receives commands through the Serial port to a Ruby Multithreading process that stores events and exposes a JSON API.

This is a project for an University's Course and a playground for me to try things with my Arduino Board and Ruby. This is **NOT** a production ready project but if you find something useful that you've been searching for i'm happy with that.

# What's this?

This is a DIY watering system for plants made with a circuit connected to an Arduino Board, the board is connected to a Raspberry Pi that interacts with the board through the USB port. The board receives commands sends log events in JSON format. The Raspberry Pi receives the log events and stores them in a SQLite database, also exposes a Web API to control the watering system and check out it's state. Finally there's a Web UI to interact with the API easily.

# Installation

Every component needs to be installed separately, you will find the installation steps in the README file inside each of this project folders.
Start with the board, then the server and then the client(optional).