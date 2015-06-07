/*
 currentState: max 26 simultaneous waves
 pb: mesh's drawVertices() does not seem to be able to draw more than 1px -> too small
*/

/*
flags:
    FIXME: ...
    OPTIM: ...
    TODO: ...
*/

#pragma once

#include "ofMain.h"
#include "ofxiOS.h"
#include "ofxiOSExtras.h"
#include "connection.h"
#include "PointElement.h"
#include "Game.h"
#include "errno.h"
#include "Calibrator.h"

class ofApp : public ofxiOSApp {
	
    public:
        void setup();
        void update();
        void draw();
        void exit();
	
        void touchDown(ofTouchEventArgs & touch);
        void touchMoved(ofTouchEventArgs & touch);
        void touchUp(ofTouchEventArgs & touch);
        void touchDoubleTap(ofTouchEventArgs & touch);
        void touchCancelled(ofTouchEventArgs & touch);

        void lostFocus();
        void gotFocus();
        void gotMemoryWarning();
        void deviceOrientationChanged(int newOrientation);
    
        // events
        void initServer();
        void onServerEvent(string & e);
        void onDeviceEvent(string & e);
        void onDataEvent(string & e);
        void onTapEvent(ofVec2f & e);
        connection serverConnection;
        ofVec2f testPos;
        Game game;
    
        // utils
        void split(const string& s, char c, vector<string>& v);
        Calibrator cal;
    
        //settings
        bool connect;
        bool serverInterface;
        bool debug;
        int cmToPx;
};


