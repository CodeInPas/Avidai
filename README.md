# Video AI Object Detector - Offline Audit Tool

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
