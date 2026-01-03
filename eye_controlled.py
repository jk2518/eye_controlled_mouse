import cv2 
import mediapipe as mp
import numpy as np
import pyautogui
cam = cv2.VideoCapture(0)

if not cam.isOpened():
    print("Error: Could not open camera.")
    exit()

face_mesh = mp.solutions.face_mesh.FaceMesh(refine_landmarks=True)
screen_width, screen_height = pyautogui.size()

# Variables for smoothing
smoothening = 5
plocX, plocY = 0, 0
clocX, clocY = 0, 0

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
    
    if landmark_points:
        landmarks = landmark_points[0].landmark
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
                
        left = [landmarks[145], landmarks[159]]
        for landmark in left:
            x = int(landmark.x * frame_width)
            y = int(landmark.y * frame_height)
            cv2.circle(frame, (x, y), 3, (0, 255, 0))
            
        if (left[0].y - left[1].y) < 0.004: # Adjusted threshold
            pyautogui.click()
            cv2.waitKey(300) # Non-blocking delay for debounce
            
    cv2.imshow("Eye_controlled_mouse", frame)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cam.release()
cv2.destroyAllWindows()
