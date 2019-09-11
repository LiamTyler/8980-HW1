String rootDir = "/home/liam/Documents/8980-HW1/";

int SW = 800;
int SH = 1000;

class Player
{
  Player()
  {
    size           = new PVector( 26, 16 );
    pos            = new PVector( SW / 2, SH - 20 );
    vel            = new PVector( 0, 0 );
    sprite         = loadImage( rootDir + "assets/player_sprite.png" );
    speed          = 10;
    keysPressed[0] = 0;
    keysPressed[1] = 0;
  }
  PVector size;
  PVector pos;
  PVector vel;
  PImage sprite;
  float speed;
  int[] keysPressed = new int[2];
};

Player player;

class Enemy
{
  Enemy()
  {
    pos  = new PVector( 0, 0 );
    vel  = new PVector( 0, 0 );
    size = new PVector( 10, 10 );
  }
  PVector pos;
  PVector vel;
  PVector size;
};
int MAX_ENEMIES = 50;
Enemy[] enemies = new Enemy[MAX_ENEMIES];
int numEnemies  = 0;
int lastEnemySpawnTime = 0;

void setup()
{
  size( 100, 100 );
  surface.setSize( SW, SH );
  frameRate( 60 );
  
  playerPos = new PVector( SW / 2, SH - playerHeight - 20 );
  playerImg = loadImage( rootDir + "assets/player_sprite.png" );
}

void update( float dt )
{
  playerPos.x += dt * 5 * ( keysPressed[1] - keysPressed[0] );
  playerPos.x = max( 0, min( SW - playerWidth, playerPos.x ) );
  
  for ( int i = 0; i < numEnemies; ++i )
  {
    enemies[i].pos.add( PVector.mult( enemies[i].vel, dt ) );
    
    if ( enemies[i].pos.y >= SH )
    {
      enemies[i] = enemies[numEnemies - 1];
      --i;
      --numEnemies;
    }
  }
  
  if ( millis() - lastEnemySpawnTime > 100 && random( 1 ) < .1 && numEnemies < MAX_ENEMIES )
  {
    enemies[numEnemies]     = new Enemy();
    enemies[numEnemies].pos = new PVector( random( 1 ) * SW, 10 );
    enemies[numEnemies].vel = new PVector( 0, 3 );
    ++numEnemies;
    lastEnemySpawnTime = millis();
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
