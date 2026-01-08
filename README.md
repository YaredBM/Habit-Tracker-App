# EcoHabit - Student-Centered Habit Tracker

EcoHabit is a high-performance, cross-platform mobile application developed with **Flutter**. It is specifically designed to help students manage academic routines through consistency, intelligent suggestions, and robust data management. This project serves as the Final Project for the **Software Engineering 2** course at the **University of Europe for Applied Sciences**.

---

## Key Features

* **Offline-First Workflow:** Full functionality without internet access using Hive local storage.
* **Cloud Synchronization:** Seamless data persistence across devices via Firebase Firestore.
* **AI Discovery & Routines:** "Explore" module with routine templates (e.g., Focus Boost, Morning Routine).
* **Data Visualization:** Interactive Monthly Heatmaps and Streak counters to monitor progress.
* **Secure Authentication:** Integrated Email/Password and Social Auth (Google/Facebook).
* **Daily Journaling:** Qualitative reflection tool to complement quantitative habit tracking.

---

## System Architecture

The application implements a strict **MVVM (Model-View-ViewModel)** architectural pattern to ensure scalability and ease of testing.

* **Presentation Layer:** Handles UI rendering (Screens, Widgets, and Theme management).
* **Application Logic (Providers):** Acts as the bridge between UI and Data; manages the state of habits and user sessions.
* **Domain Models:** Core entities defining the structure of Habits, Users, and Journal entries.
* **Infrastructure Layer:** Handles external services including Firebase (Firestore/Auth), Local DB (Hive), and AI recommendations.

---

## Technical Stack

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **State Management:** [Provider](https://pub.dev/packages/provider)
* **Local Database:** [Hive](https://docs.hivedb.dev/) (NoSQL)
* **Backend Services:** [Firebase](https://firebase.google.com/) (Auth & Firestore)
* **Diagramming:** PlantUML & Mermaid (UML Standards)

---

## Installation & Setup

### Prerequisites
* Flutter SDK (v3.19.0 or higher)
* Dart SDK (v3.3.0 or higher)
* Android Studio / VS Code

### Steps
1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/YaredBM/Habit-Tracker-App.git](https://github.com/YaredBM/Habit-Tracker-App.git)
    ```
2.  **Navigate to the project:**
    ```bash
    cd Habit-Tracker-App
    ```
3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Firebase Configuration:**
    * Place your `google-services.json` file in the `android/app/` directory.
   
5.  **Run the application:**
    ```bash
    flutter run
    ```

---

## Design Artifacts
The repository includes comprehensive engineering documentation:
* **SRS:** Detailed Functional and Non-functional requirements.
* **Class Diagrams:** Detailed object-oriented structure.
* **Use Case Diagrams:** Comprehensive maps of system-user interactions.
* **QA Report:** Testing strategy following the **IDEAL Model**.

<img width="9608" height="5915" alt="Class Diagram 3" src="https://github.com/user-attachments/assets/e129c150-0553-4e65-88b1-0e595a3928fd" />

---

## Contributors
* **Josue Pavon**
* **Yared Bustillo**
* **Jonathan Concha**
* **Liana Mikhailova**

---

## Academic Context
* **Course:** Software Engineering 2 
* **Institution:** University of Europe for Applied Sciences
* **Professor:** Ali Mehmood Khan
* **Date:** January 9, 2026
