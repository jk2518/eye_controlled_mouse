# Eye Controlled Mouse

Control your computer mouse using only your eyes! This project uses computer vision to track your eye movements and blink gestures, translating them into cursor movements and clicks.

## 🚀 Features
- **Hands-Free Control:** Move the mouse cursor by looking around the screen.
- **Blink to Click:** Perform a left-click by blinking your eye.
- **Smooth Tracking:** Includes a smoothing algorithm to reduce cursor jitter.
- **Real-Time Performance:** Built with OpenCV and MediaPipe for fast and accurate tracking.

## 🛠️ Tech Stack
- **Python 3.x**
- **OpenCV:** For video capture and image processing.
- **MediaPipe:** For robust face mesh and iris tracking.
- **PyAutoGUI:** For controlling the mouse cursor programmatically.
- **NumPy:** For numerical operations.

## 📦 Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/yourusername/eye-controlled-mouse.git
    cd eye-controlled-mouse
    ```

2.  **Create a virtual environment (optional but recommended):**
    ```bash
    python -m venv venv
    # Windows
    .\venv\Scripts\activate
    # Mac/Linux
    source venv/bin/activate
    ```

3.  **Install dependencies:**
    ```bash
    pip install -r requirements.txt
    ```

## 🎮 Usage

1.  Run the script:
    ```bash
    python eye_controlled.py
    ```
2.  **Move Cursor:** Look at different parts of your screen. The green dots on your eye show the tracking points.
3.  **Click:** Blink your left eye to click.
4.  **Quit:** Press `q` to exit the application.

## ⚙️ Configuration
You can adjust the sensitivity in `eye_controlled.py`:
- `smoothening`: Increase this value (e.g., 5-10) for smoother but slower movement.
- Blink Threshold: Adjust the value `0.004` in the blink detection logic if clicks are too sensitive or not sensitive enough.

## 🤝 Contributing
Contributions are welcome! Feel free to open issues or submit pull requests.

## 📄 License
This project is open source and available under the [MIT License](LICENSE).
