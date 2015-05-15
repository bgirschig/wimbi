#include "Particle.h"

#include "Wave.h"

Particle::Particle(int index, float _x, float _y, double direction, float _speed)
{
    position.x = _x;
    position.y = _y;
    
    speed.set(cos(direction)*_speed,sin(direction)*_speed);
    
    alive = true;
    killWave = false;
}

void Particle::update(float _speed){
    position+=speed*_speed;
    
    // bounce
    // ?

    // kill
    if(position.x<0 || position.x>ofGetWidth() || position.y<0 || position.y>ofGetHeight()) alive = false;
    
    // killWave
    if(position.x>ofGetWidth()/2) killWave=true;
}