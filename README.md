# DriversPicking

## About

## Overview:

This project is intentionally open-ended. The goal of this project is to show the use of Apple API's usage and Reactive Programming.

## App Premise:

- The user when entered for the first time it will be asked to use the current location, whem the app is in use.
- All placemarks will be custom, one for the drivers and one for the user
- The app will then fetch some drivers from https://sheetdb.io/api/v1/pc1ght2w5p69l.
- The app will generate random Coordinates and position the drivers previously fetched in the map. The positions will always be near the user locations.
- The app will refresh the drivers position every 5 seconds as well as the user positions if needed.
- If a driver is selected, the app will have an info view showing the current address, name, image from the driver and the distance/time from the user location.
- Also, if selected, the driver will have a different image on the map to distinguish it from the other drivers.
- If a driver is not selected there will be an info view showing the current address, name (USER), image (placeholder) and date.
