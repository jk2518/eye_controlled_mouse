import cv2 
import mediapipe as mp
import numpy as np
import pyautogui
import math

cam = cv2.VideoCapture(0)

if not cam.isOpened():
    print("Error: Could not open camera.")
    exit()

face_mesh = mp.solutions.face_mesh.FaceMesh(refine_landmarks=True)
screen_width, screen_height = pyautogui.size()

# Variables for smoothing
plocX, plocY = 0, 0
clocX, clocY = 0, 0

def calculate_ear(landmarks, indices, frame_width, frame_height):
    # indices: [left, top1, top2, right, bottom1, bottom2]
    # Corresponds to: P1, P2, P3, P4, P5, P6
    
    coords = []
    for i in indices:
        lm = landmarks[i]
        coords.append((int(lm.x * frame_width), int(lm.y * frame_height)))
        
    def dist(p1, p2):
        return math.sqrt((p1[0] - p2[0])**2 + (p1[1] - p2[1])**2)

    # Vertical distances
    # P2 (160) - P6 (144)
    A = dist(coords[1], coords[5])
    # P3 (158) - P5 (153)
    B = dist(coords[2], coords[4])

    # Horizontal distance
    # P1 (33) - P4 (133)
    C = dist(coords[0], coords[3])

    if C == 0: return 0
    ear = (A + B) / (2.0 * C)
    return ear

# MediaPipe indices for Left Eye
# 33: Left corner, 133: Right corner
# 160, 158: Top
# 144, 153: Bottom
left_eye_indices = [33, 160, 158, 133, 153, 144]

# Create window and trackbars
cv2.namedWindow("Eye_controlled_mouse")
def nothing(x):
    pass

# Range 0-100 for threshold (divided by 100 later) -> 0.0 to 1.0
cv2.createTrackbar("Threshold", "Eye_controlled_mouse", 25, 100, nothing)
# Range 1-30 for smoothening
cv2.createTrackbar("Smooth", "Eye_controlled_mouse", 5, 30, nothing)

while True:
    ret, frame = cam.read()
    if not ret:
        print("Error: Failed to read frame from camera.")
        break
        
    frame = cv2.flip(frame, 1) # Flip frame horizontally for mirror view
    rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    output = face_mesh.process(rgb_frame)
    landmark_points = output.multi_face_landmarks
    frame_height, frame_width, _ = frame.shape
    
    # Read trackbar values
    thresh_val = cv2.getTrackbarPos("Threshold", "Eye_controlled_mouse") / 100.0
    smoothening = cv2.getTrackbarPos("Smooth", "Eye_controlled_mouse")
    if smoothening < 1: smoothening = 1
    
    if landmark_points:
        landmarks = landmark_points[0].landmark
        
        # --- Cursor Movement (Iris Tracking) ---
        for id, landmark in enumerate(landmarks[474:478]):
            x = int(landmark.x * frame_width)
            y = int(landmark.y * frame_height)
            cv2.circle(frame, (x, y), 3, (0, 255, 0))
            
            if id == 1:
                # Screen Mapping with Smoothing
                screen_x = np.interp(x, (0, frame_width), (0, screen_width))
                screen_y = np.interp(y, (0, frame_height), (0, screen_height))
                
                # Smoothening logic
                clocX = plocX + (screen_x - plocX) / smoothening
                clocY = plocY + (screen_y - plocY) / smoothening
                
                pyautogui.moveTo(clocX, clocY)
                plocX, plocY = clocX, clocY
        
        # --- Blink Detection (EAR) ---
        ear = calculate_ear(landmarks, left_eye_indices, frame_width, frame_height)
        
        # Visualize eye landmarks
        for i in left_eye_indices:
            x = int(landmarks[i].x * frame_width)
            y = int(landmarks[i].y * frame_height)
            cv2.circle(frame, (x, y), 2, (0, 255, 255))

        # Display current EAR and Threshold on screen
        cv2.putText(frame, f"EAR: {ear:.2f}", (300, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
        cv2.putText(frame, f"Thresh: {thresh_val:.2f}", (300, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)

        if ear < thresh_val: 
            pyautogui.click()
            cv2.putText(frame, "BLINK CLICK!", (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255), 2)
            cv2.waitKey(300) # Debounce
            
    cv2.imshow("Eye_controlled_mouse", frame)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cam.release()
cv2.destroyAllWindows()
