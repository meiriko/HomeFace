import processing.opengl.*;

// Global variables
float radius = 50.0;
int X, Y;
public boolean ignoreMouse = false;
int nX, nY;
int delay = 16;

// Setup the Processing Canvas
void setup(){
	size( 400, 300 );
	// size( 400, 300 , OPENGL);
	strokeWeight( 10 );
	frameRate( 15 );
	X = width / 2;
	Y = height / 2;
	nX = X;
	nY = Y;	
}

void setIgnoreMouse( boolean value ) {
	ignoreMouse = value;
}

boolean getIgnoreMouse() {
	return (ignoreMouse);
}

// Main draw loop
void draw(){
	strokeWeight( 10 );
	radius = radius + sin( frameCount / 4 );
	
	// Track circle to new destination
	X+=(nX-X)/delay;
	Y+=(nY-Y)/delay;
	
	// Fill canvas grey
	background( 0,0 ); 
	// Set fill-color to blue
	fill( 0, 121, 184 );
	
	// Set stroke-color white
	stroke(255); 
	
	// Draw circle
	ellipse( X, Y, radius, radius );									
	strokeWeight( 2 );
}


// Set circle's next destination
void mouseMoved(){
	if(ignoreMouse){
		return;
	}
	nX = width - mouseX;
	nY = mouseY;	
}
