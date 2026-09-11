

## Python Environment & Libraries Setup

To run the AI object detection engine locally without requiring a full system-wide Python installation, follow these steps to set up an embedded Python environment:

### 1. Download Embedded Python
1. Visit the official Python website and download the **Python Embedded Package (Zip)** for **Python 3.12** (64-bit).
2. Create a folder named `python_embed` in the root directory of your Lazarus project.
3. Extract all contents of the downloaded Zip file directly into the `python_embed` folder.

### 2. Enable Site-Packages (Crucial Step)
By default, the embedded version of Python disables external libraries (`site-packages`). To fix this:
1. Open the `python312._pth` file located inside your `python_embed` folder using a text editor (e.g., Notepad).
2. Look for the line `#import site` and **uncomment it** by removing the `#` character so it reads:
   ```text
python312.zip
.
Lib\site-packages
import site




3. Save and close the file.

### 3. Install Pip (Package Manager)

Since the embedded package does not come with `pip` pre-installed:

1. Download the official installation script from [get-pip.py](https://bootstrap.pypa.io/get-pip.py) and save it inside the `python_embed` folder.
2. Open your command prompt (CMD) in the project directory and run the following command to install pip into the embedded environment:
```bash
python_embed\python.exe python_embed\get-pip.py

```



### 4. Install Required AI Libraries

Once `pip` is installed, run the following commands in your command prompt to install YOLOv8, OpenCV, and PyTorch (CPU version recommended for offline stability):

```bash
python_embed\python.exe -m pip install ultralytics opencv-python torch torchvision --index-url [https://download.pytorch.org/whl/cpu](https://download.pytorch.org/whl/cpu)

```

### 5. Verify Structure

Ensure your `python_embed` directory contains the necessary DLLs and site-packages so that `PythonEngine` in Lazarus can detect and initialize it automatically upon execution.

```text
python_embed/
├── python.exe
├── python312.dll
├── python312._pth
├── Lib/
│   └── site-packages/    # Contains torch, ultralytics, cv2, etc.
└── ...

```

```

```
