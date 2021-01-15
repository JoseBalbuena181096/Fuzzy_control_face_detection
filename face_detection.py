#!/usr/bin/env python3
# import the opencv library 
import cv2 
import serial    
import time
import numpy as np
import skfuzzy as fuzz
from skfuzzy import control as ctrl

class fuzzy_control:
    def __init__(self, cols,rows):
        self.x = cols
        self.y = rows

        self.position_y = ctrl.Antecedent(np.arange(0,self.y+1,1), 'position_y')
        self.position_x = ctrl.Antecedent(np.arange(0,self.x+1,1), 'position_x')

        self.position_y['very_low'] = fuzz.trimf(self.position_y.universe,[0,0,self.y*0.25])
        self.position_y['low'] = fuzz.trimf(self.position_y.universe, [0,0.25*self.y,0.5*self.y])
        self.position_y['center'] = fuzz.trimf(self.position_y.universe, [0.25*self.y,0.5*self.y,0.75*self.y])
        self.position_y['high'] = fuzz.trimf(self.position_y.universe, [0.5*self.y,0.75*self.y,self.y])
        self.position_y['very_high'] = fuzz.trimf(self.position_y.universe, [0.75*self.y,self.y,self.y])

        self.position_x['very_left'] = fuzz.trimf(self.position_x.universe,[0,0,self.x*0.25])
        self.position_x['left'] = fuzz.trimf(self.position_x.universe, [0,0.25*self.x,0.5*self.x])
        self.position_x['center'] = fuzz.trimf(self.position_x.universe, [0.25*self.x,0.5*self.x,0.75*self.x])
        self.position_x['right'] = fuzz.trimf(self.position_x.universe, [0.5*self.x,0.75*self.x,self.x])
        self.position_x['very_right'] = fuzz.trimf(self.position_x.universe, [0.75*self.x,self.x,self.x])

        self.output_y = ctrl.Consequent(np.arange(-40,40, 1), 'output_y')
        self.output_x = ctrl.Consequent(np.arange(-40,40, 1), 'output_x')

        self.output_y['very_low'] = fuzz.trimf(self.output_y.universe,[-30,-20,-10])
        self.output_y['low'] = fuzz.trimf(self.output_y.universe,[-20,-10,0])
        self.output_y['center'] = fuzz.trimf(self.output_y.universe,[-10,0,10])
        self.output_y['high'] = fuzz.trimf(self.output_y.universe, [0,10,20])
        self.output_y['very_high'] = fuzz.trimf(self.output_y.universe, [10,20,30])

        self.output_x['very_left'] = fuzz.trimf(self.output_x.universe,[-30,-20,-10])
        self.output_x['left'] = fuzz.trimf(self.output_x.universe, [-20,-10,0])
        self.output_x['center'] = fuzz.trimf(self.output_x.universe,[-10,0,10])
        self.output_x['right'] = fuzz.trimf(self.output_x.universe,[0,10,20])
        self.output_x['very_right'] = fuzz.trimf(self.output_x.universe,[10,20,30])

        self.y_str = ['very_low','low','center','high','very_high']
        self.x_str = ['very_left','left','center','right','very_right']

        self.rules = []

        for i in range(5):
            for j in range(5):
                self.rules.append(ctrl.Rule(self.position_y[self.y_str[i]] & self.position_x[self.x_str[j]],consequent=[self.output_y[self.y_str[i]],self.output_x[self.x_str[j]]]))

        self.position_ctrl = ctrl.ControlSystem(self.rules)
        self.position = ctrl.ControlSystemSimulation(self.position_ctrl)


    def get_correction(self,pos_x,pos_y):
        #control fuzzy
        position = []
        self.position.input['position_y'] = self.y-pos_y
        self.position.input['position_x'] = pos_x
        self.position.compute()
        position.append(self.position.output['output_x'])
        position.append(self.position.output['output_y'])
        return position


# define a video capture object 
if __name__ == '__main__':
    arduino = serial.Serial('/dev/ttyUSB0', 9600)
    time.sleep(2)
    control = fuzzy_control(640,480)
    vid = cv2.VideoCapture(0) 
    faceClassif = cv2.CascadeClassifier('haarcascade_frontalface_default.xml')  
    x,y = -1,-1
    rows,cols = 0,0
    while(True): 
        # Capture the video frame 
        # by frame 

        ret, frame = vid.read() 
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        faces = faceClassif.detectMultiScale(gray,scaleFactor = 1.3, minNeighbors = 5, minSize=(60,60), maxSize = (300,300))
        #serial.data_read()
        for (x,y,w,h) in faces:
            cv2.rectangle(frame, (x,y),(x+w,y+h),(0,255,0),5)   
            cv2.line(frame,(x+int(w/2),0),(x+int(w/2),int(frame.shape[0])),(255,0,0),2)
            cv2.line(frame,(0,y+int(h/2)),(int(frame.shape[1]),y+int(h/2)),(255,0,0),2)
            cv2.circle(frame,(x+int(w/2),y+int(h/2)), 5, (0,0,255),10)     
            positionText = "("+str(x+int(w/2))+","+str(y+int(h/2))+")"
            cv2.putText(frame,positionText, (x,y), cv2.FONT_HERSHEY_SIMPLEX,1,(0,255,255))
            x = int(x+(w/2))
            y = int(y+(h/2))
            cols = frame.shape[1]
            rows = frame.shape[0]
            cv2.line(frame,(int(cols/2),0),(int(cols/2),int(rows)),(0,0,255),4)
            #print(frame.shape[1]/2)
        position = control.get_correction(x,y)
        print("X: {:.2f} , Y: {:.2f} ".format(position[0],position[1]))
        cv2.imshow('frame',frame)
        # the 'q' button is set as the 
        # quitting button you may use any 
        # desired button of your choice 
        if cv2.waitKey(1) & 0xFF == ord('q'): 
            break
        data = '{:.2f},{:.2f}\n'.format(position[0],position[1])
        data = data.encode()
        arduino.write(data)
        
    # After the loop release the cap object 
    arduino.close()
    vid.release() 
    # Destroy all the windows 
    cv2.destroyAllWindows() 