# Smart Motorcycle Helmet

[Watch the Demo Video](https://youtu.be/EaheAvZVrQg?si=x12echzrcBc7yG3L)

## Overview

The Smart Motorcycle Helmet is designed to enhance rider safety and emergency response through real-time alerts and monitoring. Built as part of a senior design project at the University of Pittsburgh, the system integrates crash detection, blind spot monitoring, forward collision warnings, and automatic emergency contact notifications through a connected mobile app.

## Key Features

- Crash Detection: Detects impact using force-sensitive resistors and/or IMU data.
- Emergency Alerts: Automatically texts emergency contacts with the rider's location after a crash, significant location change, or safety confirmation.
- Manual Trigger: Allows users to manually trigger and cancel crash alerts via the helmet or the app.
- Live Location Sharing: Emergency contacts can reply “UPDATE” to receive the rider’s current GPS location.
- Blind Spot Detection: Alerts the rider with LED indicators when a vehicle enters the blind spot.
- Forward Collision Warning: Warns the rider of vehicles or obstacles directly ahead using ultrasonic sensors.
- Bluetooth Communication: Connects the helmet and app using Bluetooth Low Energy (BLE).
- Flutter App: Mobile interface for configuring contacts, monitoring crash status, and sending alerts.

## System Architecture

The system consists of three main components:

- Helmet Hardware: Built using an Arduino-compatible microcontroller, ultrasonic sensors, LEDs, force-sensitive resistors, and a Bluetooth module.
- Flutter Mobile App: Communicates with the helmet and manages emergency contact alerts via the Twilio API.
- Backend Logic: Written in Dart with Firebase integration for user settings, messaging, and location tracking.
