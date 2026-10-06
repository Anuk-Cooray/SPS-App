# AI Vision-Based Smart Parking System (SPS) - Mobile Application

**Project ID:** J26-IT-335  
**Institution:** Sri Lanka Institute of Information Technology (SLIIT)  
**Department:** Department of Information Technology  
**Specialization:** Information Technology (IT)  
**Research Cluster:** AIMS (Autonomous Intelligent Machines and Systems)  
**Supervisors:** Dr. Mahesh Liyanwatte, Ms. Malithi Nawaratne  

---

## 📌 Project Overview
Urban centers in Sri Lanka experience acute traffic gridlocks, with drivers wasting considerable time and fuel searching for parking spaces. Existing parking systems treat reservations as fixed, one-time transactions: if conditions change, the driver is never offered a closer spot; if a driver fails to arrive, the spot remains hoarded while others circle the block.

This project delivers an integrated, real-time, vision-enabled and IoT-assisted Smart Parking System featuring **Dynamic Slot Re-Optimization**, **15-Minute Auto-Cancellation**, **CCTV YOLO Occupancy & Multi-Slot Violation Detection**, **Dynamic Time-Sensitive QR Billing**, and **IoT Smart Barrier Actuation**.

---

## 👥 Research Team & Individual Responsibilities

The codebase is partitioned according to the approved SLIIT IT4010 Research Charter:

| Member Name | Student ID | Sub-Objective & Novelty | Assigned Directory |
| :--- | :--- | :--- | :--- |
| **Cooray T.C.M.G.A.I** (*Leader*) | `IT23328020` | **Dynamic Slot Re-optimization & Reservation Model**<br>• 15-minute auto-cancellation TTL engine<br>• 10-minute pre-arrival AI upgrade rerouting algorithm<br>• Dynamic booking and upgrade acceptance workflow | `lib/features/reservation/` |
| **R.M.M.K.S Rathnayake** | `IT23333666` | **Hybrid Payment Analytics & Automated Billing Model**<br>• Dynamic fee calculation engine (duration + peak factor)<br>• Single-use time-sensitive QR code generator for exit<br>• Mobile self-payment & guard-assisted booth checkout | `lib/features/payment_billing/` |
| **G.V.K Samudi** | `IT23343498` | **Vision-Based Occupancy & Violation Detection Model**<br>• CCTV video stream occupancy monitoring<br>• Fine-tuned YOLO detection for local vehicles (tuk-tuks, cars)<br>• Multi-slot improper parking violation alert dispatch | `lib/features/occupancy_vision/` |
| **R. Varunprasath** | `IT23347526` | **IoT-Driven Physical Slot Protection & Authentication**<br>• ESP32 smart bollard/barrier actuation (Raise/Lower)<br>• QR-based entry gate verification<br>• "Find My Car" automatic location saver & reverse navigation | `lib/features/iot_navigation/` |

---

## 🏗️ Repository Architecture

This repository adopts **Clean Feature-Driven Architecture** to ensure members can build their components in complete isolation without merge conflicts:

```
sps-mobile-app/
├── android/                         # Android native configurations & permissions
├── assets/                          # Images, icons, and mock lot layouts
│   ├── icons/
│   └── images/
├── lib/
│   ├── core/                        # Shared Foundation (Core Shell)
│   │   ├── constants/               # System limits (15-min TTL, 10-min window)
│   │   ├── models/                  # ParkingSlot, Reservation, ViolationRecord
│   │   └── theme/                   # Modern dark automotive theme palette
│   │
│   ├── shared_widgets/              # Shared UI Widgets
│   │   ├── countdown_timer_widget.dart  # 15-min real-time auto-release timer
│   │   ├── custom_button.dart       # Modern styled button
│   │   └── status_badge.dart        # Available/Reserved/Occupied/Violation pills
│   │
│   ├── features/                    # Individual Team Feature Modules
│   │   ├── reservation/             # [COORAY] Dynamic Slot Booking & Re-optimization
│   │   ├── payment_billing/         # [RATHNAYAKE] Dynamic QR Exit & Billing
│   │   ├── occupancy_vision/        # [SAMUDI] CCTV Feed & Multi-Slot Violations
│   │   └── iot_navigation/          # [VARUNPRASATH] Smart Bollards & Find My Car
│   │
│   └── main.dart                    # App Entry Point & 4-Tab Navigation Shell
├── pubspec.yaml                     # Dependencies & Asset configuration
└── README.md
```

---

## 🚀 Getting Started

### 1. Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.0.0 or higher)
* [Android Studio](https://developer.android.com/studio) or VS Code with Flutter extension
* Android Device or Emulator (API 21+)

### 2. Setup & Installation
```bash
# Clone the repository
git clone <your-git-repo-url>
cd "SPS App"

# Fetch project dependencies
flutter pub get

# Run on connected device / emulator
flutter run
```

---

## 🌿 Git Branching & Collaboration Guidelines

To maintain repository integrity and clear academic attribution:

1. **`main` Branch**: Contains stable, production-ready code. No direct commits allowed.
2. **Branch Naming Conventions**:
   * Cooray: `git checkout -b feat/reservation-dynamic-reopt`
   * Rathnayake: `git checkout -b feat/billing-dynamic-qr`
   * Samudi: `git checkout -b feat/vision-occupancy-violations`
   * Varunprasath: `git checkout -b feat/iot-barrier-find-car`
3. **Merging Workflow**:
   * Commit within your designated `lib/features/<your-feature>/` directory.
   * Push your feature branch and open a Pull Request (PR) to `main`.
   * Test before approving PRs.
