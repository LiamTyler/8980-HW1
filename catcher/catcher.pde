String rootDir = "/home/liam/Documents/8980-HW1/";

int SW = 800;
int SH = 1200;

int playerWidth  = 26;
int playerHeight = 16;

PVector playerPos;
int[] keysPressed = { 0, 0 }; // [0] == left, [1] == right
PImage playerImg;

class Enemy
{
  PVector pos;
  PVector vel;
  PVector size;
};
int MAX_ENEMIES = 100;
Enemy[] enemies = new Enemy[MAX_ENEMIES];
int numEnemies  = 0;

void setup()
{
  size( 100, 100 );
  surface.setSize( SW, SH );
  
  playerPos = new PVector( SW / 2, SH - playerHeight - 20 );
  playerImg = loadImage( rootDir + "assets/player_sprite.png" );
  
  for ( int i = 0; i < MAX_ENEMIES; ++i )
  {
    enemies[i] = new Enemy();
    enemies[i].size = new PVector( 10, 10 );
  }
}

void update( float dt )
{
  playerPos.x += dt * 5 * ( keysPressed[1] - keysPressed[0] );
  playerPos.x = max( 0, min( SW - playerWidth, playerPos.x ) );
  
  for ( int i = 0; i < numEnemies; ++i )
  {
    enemies[i].pos.add( enemies[i].vel );
  }
  
  if ( random( 1 ) < .2 && numEnemies < MAX_ENEMIES )
  {
    println( numEnemies );
    enemies[numEnemies].pos = new PVector( random( 1 ) * SW, 10 );
    ++numEnemies;
  }
}

void draw()
{
  update( 1 );
  
  background( 0, 0, 0 );
  image( playerImg, playerPos.x, playerPos.y, playerWidth, playerHeight );
  
  for ( int i = 0; i < numEnemies; ++i )
  {
    rect( enemies[i].pos.x, enemies[i].pos.y, enemies[i].size.x, enemies[i].size.y );
  }
}

void keyPressed() {
  if ( key == CODED )
  {
    if (keyCode == LEFT )
    {
      keysPressed[0] = 1;
    }
    else if (keyCode == RIGHT )
    {
      keysPressed[1] = 1;
    } 
  }
}

void keyReleased() {
  if ( key == CODED )
  {
    if (keyCode == LEFT )
    {
      keysPressed[0] = 0;
    }
    else if (keyCode == RIGHT )
    {
      keysPressed[1] = 0;
    } 
  }
}
