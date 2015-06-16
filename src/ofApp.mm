#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
    fonts[BIG].loadFont("assets/fonts/Melbourne_light.otf", 100);
    fonts[MEDIUM].loadFont("assets/fonts/Melbourne_light.otf", 60);
    fonts[SMALL].loadFont("assets/fonts/Melbourne_light.otf", 40);

    // load sounds
    for (int i=0; i<5; i++) tapSounds[i].loadSound("assets/tapSounds/tap"+ofToString(i)+".mp3");
    for (int i=0; i<3; i++) validSounds[i].loadSound("assets/validSounds/valid"+ofToString(i)+".mp3");
    for (int i=0; i<3; i++) wrongSounds[i].loadSound("assets/wrongSounds/"+ofToString(i)+".mp3");
    for (int i=0; i<1; i++) upSounds[i].loadSound("assets/upSounds/"+ofToString(i)+".mp3");
    
    ofBackground(0);
    
    // settings
    debug = false;
    connect = true;
    serverInterface = false;
    touchDebug = false;

    // events / sensors
    initEvents();
    ofxAccelerometer.setup();
    
    if(connect){
//         serverConnection.setup("10.206.104.38", 11999); //lab
         serverConnection.setup("10.0.1.9", 11999); // ecal install
//        serverConnection.setup("10.192.249.242", 11999); //mbp connection
        cal.init(fonts, &serverConnection);
        serverConnection.send("calibration:start");
    }
    else{
        cal.done = true;
        game.init(fonts);
        
        game.simulateTouch = touchDebug;
    }
}

//--------------------------------------------------------------
void ofApp::update(){
    if(abs(ofxAccelerometer.getOrientation().x)>2 && game.active){
        serverConnection.send("calibration:start");
        game.active = false;
        cal.init(fonts, &serverConnection);
        for(int i=game.waves.size()-1; i>=0; i--) game.killWave(i);
    }
    
    // orientation fix
    if(ofxiOSGetGLView().frame.origin.x != 0 || ofxiOSGetGLView().frame.size.width != [[UIScreen mainScreen] bounds].size.width) ofxiOSGetGLView().frame = CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height);
    
    if(connect) serverConnection.update();

    if(game.active) game.update();
    if(!cal.done) {
        cal.update();
        if(cal.done) game.init(fonts);
    }
}

//--------------------------------------------------------------
void ofApp::draw(){
    if(debug){}
    if(!cal.done && serverConnection.Connected) cal.draw();
    if(game.active) game.draw();
    if(connect && serverInterface) serverConnection.drawInterface();
    if(debug){ ofSetColor(255); ofDrawBitmapString(ofToString(ofGetFrameRate())+"fps", 500, 15); }
    if(!serverConnection.Connected && connect){
        ofSetColor(0,30); ofFill(); ofRect(0, 0, ofGetWidth(), ofGetHeight());
        ofSetColor(Colors[GAME_OBJ]);
        ofRectangle shape = fonts[SMALL].getStringBoundingBox("You are not connected. Please check your network", 0, 0);
        fonts[SMALL].drawString("You are not connected. Please check your network", 1024-shape.width/2, 1450);
    }
}

void ofApp::exit(){}

void ofApp::touchDown(ofTouchEventArgs & touch){
    // on touch, send position to server for calinration. (if calibration is not done)
    if(connect && serverConnection.Connected && !cal.done) serverConnection.send("calibration:"+ofToString(touch.x)+","+ofToString(touch.y));
    if(touchDebug && !connect) onTapEvent(touch);
}

void ofApp::touchMoved(ofTouchEventArgs & touch){}
void ofApp::touchUp(ofTouchEventArgs & touch){}
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){
}
void ofApp::touchCancelled(ofTouchEventArgs & touch){}
void ofApp::lostFocus(){}
void ofApp::gotFocus(){}
void ofApp::gotMemoryWarning(){}
void ofApp::deviceOrientationChanged(int newOrientation){}

void ofApp::initEvents(){
    if(connect){
        ofAddListener(serverConnection.tapEvent, this, &ofApp::onTapEvent);
        ofAddListener(serverConnection.tapUpEvent, this, &ofApp::onTapUpEvent);
    }
    ofAddListener(PointElement::playSoundEvent, this, &ofApp::onPlaySoundEvent);
    ofAddListener(game.soundEvent, this, &ofApp::onPlaySoundEvent);
}

void ofApp::onTapEvent(ofVec2f &e){
//    tapSounds[(int)ofRandom(5)].play();
    if(!cal.done) cal.step++;
    else{
        testPos.set(e.x, e.y);
        game.tap(e.x, e.y);
    }
}
void ofApp::onTapUpEvent(bool &e){
    
}


void ofApp::onButton(ButtonKind & kind){
    if(kind==RESTART) game.levels[game.currentLevel].completed = true;
    else cout << "btn " << kind;
}
void ofApp::onPlaySoundEvent(string & e){
    if(e == "0") tapSounds[(int)floor(ofRandom(5))].play();
    else if(e == "1") validSounds[(int)floor(ofRandom(1))].play();
    else if(e == "2") wrongSounds[(int)floor(ofRandom(1))].play();
    else if(e == "3") upSounds[(int)floor(ofRandom(1))].play();
}
