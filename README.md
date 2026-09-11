

# Video AI Object Detector - Offline Audit Tool

<img width="964" height="605" alt="Avidai" src="https://github.com/user-attachments/assets/475e89f5-0d08-456d-b306-c62e192c9d31" />

A high-performance, multithreaded offline video auditing tool designed for automated object detection and visual verification. Built using **Lazarus (Free Pascal)** for a responsive GUI and **YOLOv8 (Python)** for computer vision analysis, the application enables frame-accurate log tracking, evidence snapshot generation, and seamless video navigation.

---

## Key Features

* **Offline & Private:** Analyzes videos locally without requiring an internet connection or external API calls.
* **Non-Blocking Multithreading:** Powered by Python daemon threading and thread-safe data queues in Lazarus to keep the UI fully responsive during heavy inference.
* **Real-Time Detection Logs:** Captures detected objects along with exact video timestamps and allows live keyword filtering.
* **Frame-Accurate Video Scrubbing:** Double-clicking any log entry automatically synchronizes `PasLibVlcPlayer` to the exact millisecond and displays the annotated evidence snapshot.
* **Custom Inference Controls:** Configurable target FPS (frame skipping) and confidence thresholds to balance speed and accuracy.
* **Automated Reporting:** Generates text reports (`result.txt`) and scaled detection snapshots automatically.

---

## Tech Stack

* **GUI / Frontend:** Lazarus IDE (Free Pascal Compiler)
* **Media Engine:** PasLibVlcPlayer (libVLC integration)
* **AI Engine:** YOLOv8 via Python 3.12 (Embedded Python Engine / Python4Lazarus)
* **Computer Vision:** OpenCV (`cv2`) & PyTorch

---

## System Requirements & Directory Structure

Ensure the output executable directory includes the following dependencies:

```text
├── your_app.exe
├── engine_ai.py
├── yolov8n.pt
├── crash_debug.txt (auto-generated)
├── python_embed/           # Embedded Python 3.12 runtime
│   ├── python312.dll
│   └── ...
├── vlc_libs/               # Portable libVLC binaries and plugins
│   ├── libvlc.dll
│   ├── libvlccore.dll
│   └── plugins/
└── temp_snapshots/         # Auto-managed folder for snapshots and logs

## ☕ Support the Project

If you find **LLAMA Control Center** helpful and want to support its ongoing development, consider buying me a coffee or sending a tip. Any support is deeply appreciated!

[![Ko-fi](https://img.shields.io/badge/Ko--fi-Buy%20Me%20a%20Coffee-F16061?style=for-the-badge&logo=ko-fi&logoColor=white)](https://Ko-fi.com/ainovasinusantara)
[![PayPal](https://img.shields.io/badge/PayPal-Donate-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/KangOz)

> **💡 Your support keeps the momentum going!**  
> Every contribution directly fuels my passion, energy, and motivation to continuously build, maintain, and release even more useful open-source desktop applications for the developer community.

