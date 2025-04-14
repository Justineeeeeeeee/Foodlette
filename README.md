
# 🐔 Foodlette – IoT System for Turning Vegetable Waste into Poultry Feed

**Foodlette** is an IoT-enabled mobile platform that transforms surplus green vegetables into sustainable poultry feed. Designed to optimize cost, minimize food waste, and promote agricultural sustainability, it uses real-time sensor monitoring and a Model Predictive Control (MPC) algorithm to automate the feed production process.

---

## 🌿 Project Overview

Foodlette addresses the issue of green vegetable waste and expensive poultry feed by:

- Converting food waste into nutritious chicken feed pellets.
- Empowering farmers through a mobile app to monitor and control feed production remotely.
- Reducing methane emissions from decomposing food waste.
- Supporting the Philippine Development Plan 2023–2028 through sustainable agriculture.

---

## 🚀 Features

- 📱 **Mobile App** (Android & iOS): Remote control of pelletizing machine with start/stop, error alerts, and status monitoring.
- 📊 **Real-Time Monitoring**: Track temperature, humidity, gas levels, ingredient weights, and machine performance.
- ☁️ **Cloud Storage**: Firebase integration for saving logs, history, and user data.
- 🔐 **Secure Login**: User authentication and role-based access.
- 🔔 **Push Notifications**: Error warnings, maintenance schedules, and system downtime alerts.
- 🌍 **Language Support**: English interface.

---

## 🛠️ Tech Stack

- **Frontend**: Android Studio, Figma (UI Design)
- **Backend**: Firebase (Database, Auth, Cloud Functions)
- **IoT & Sensors**: Gas sensors, weight sensors, temperature/humidity sensors
- **3D Assets**: Blender (Machine visualizations)
- **Version Control**: Git & GitHub
- **Assisted Development**: GitHub Copilot

---

## 📦 Installation & Setup

### 🔧 Prerequisites

- Android Studio
- Firebase Project Setup
- Physical IoT sensors and pelletizing machine (connected to Firebase)
- NodeMCU/ESP32 microcontroller (for hardware interface)

### 📱 Running the App

1. Clone the repo:
   ```bash
   git clone https://github.com/YOUR_USERNAME/Foodlette.git
   ```
2. Open with Android Studio.
3. Configure Firebase keys in `google-services.json`.
4. Connect physical hardware to Firebase endpoints.
5. Run the app on an emulator or device.

---

## 🧪 Experimental Validation

- Compared traditional feed vs. Foodlette feed on poultry growth.
- Experimental group showed better feed efficiency and higher weight gain.
- No health issues observed; confirmed safety and viability of Foodlette feed.
- Economic analysis suggests cost-effectiveness due to improved conversion rates.

---

## 📊 Research Summary

| Metric             | Control Group | Experimental Group |
|--------------------|---------------|--------------------|
| Week 2 Weight Gain | 365g avg.     | 393g avg.          |
| Feed Intake        | 500g/chick    | 500g/chick         |
| Health Status      | Normal        | Normal             |
| Efficiency         | Moderate      | High               |

---

## 📚 Significance

- Promotes a **circular economy** by linking vegetable surplus suppliers and poultry farmers.
- Improves **food security** and **livelihoods** of small poultry farmers.
- Reduces reliance on **imported feed ingredients** (soy, maize).

---

## 📐 System Diagrams

- **IPO Diagram**
- **ERD**
- **Use Case Diagram**
- **Login, Dashboard, and Machine Images** *(See documentation or presentation slides)*

---

## 📄 Documentation

Detailed documentation including conceptual framework, system architecture, and experimental results is provided in the [project paper](./Copy%20of%20Format.docx).

---

## 👥 Authors

- Rosemarie A. Bullo  
- Justine M. Consulta  
- Allan Isaac Manguerra  
- Daryll T. Miguel  
- Hazel Ann A. Noquera  
- Angelo Uriel Pelagio  
- Karl Denmark B. Razon  
- **Adviser**: Prof. Joemen G. Barrios, MIT  
- 🏫 University of Caloocan City – North Campus

---

## 📅 Release Info

- **Presented in**: ITechtivity 2025 – UCC CSD Undergraduate I.T. Research Journal  
- **Edition**: May 2025
