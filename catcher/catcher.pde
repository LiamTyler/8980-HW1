String rootDir = "/home/liam/Documents/8980-HW1/";

int SW = 800;
int SH = 1000;

abstract class Moveable
{
  Moveable()
  {
    pos  = new PVector( 0, 0 );
    vel  = new PVector( 0, 0 );
    size = new PVector( 20, 20 );
  }
  PVector pos;
  PVector vel;
  PVector size;
};

class Bullet extends Moveable
{
  Bullet( PVector startPos, PVector startVel )
  {
    pos = startPos;
    vel = startVel;
  }
  
  void draw()
  {
    fill( col );
    rect( pos.x, pos.y, size.x, size.y );
  }
  
  color col;
};

class BasicBullet extends Bullet
{
  BasicBullet( PVector startPos )
  {
    super( startPos, new PVector( 0, -3 ) );
    size = new PVector( 6, 12 );
    col = color( 255, 0, 0 );
  }
};

class Weapon
{
  Weapon()
  {
    fireRate       = 500;
    bullets        = new Bullet[10];
    numBullets     = 0;
    timeOfLastFire = 0;
  }
  
  void fire( PVector pos )
  {
    int currT = millis();
    if ( currT > timeOfLastFire + fireRate )
    {
      println( "Firing: ", numBullets );
      bullets[numBullets] = new BasicBullet( pos );
      ++numBullets;
      timeOfLastFire = currT;
    }
  }
  
  void update( float dt )
  {
    for ( int i = 0; i < numBullets; ++i )
    {
      bullets[i].pos.add( PVector.mult( bullets[i].vel, dt ) );
    }
  }
  
  void draw()
  {
    for ( int i = 0; i < numBullets; ++i )
    {
      bullets[i].draw();
    }
  }
  
  int timeOfLastFire;
  int fireRate;
  Bullet[] bullets;
  int numBullets;
};

class Player extends Moveable
{
  Player()
  {
    float imgAspectRatio = 26 / 16.0;
    size           = new PVector( 50, 50 / imgAspectRatio );
    pos            = new PVector( SW / 2, SH - 20 );
    vel            = new PVector( 0, 0 );
    sprite         = loadImage( rootDir + "assets/player_sprite.png" );
    speed          = 10;
    keysPressed = new int[2];
    keysPressed[0] = 0;
    keysPressed[1] = 0;
    
    weapon = new Weapon();
  }
  
  void fire() 
  {
    weapon.fire( new PVector( pos.x, pos.y - size.y ) );
  }
  
  void update( float dt )
  {
    player.pos.x += dt * player.speed * ( player.keysPressed[1] - player.keysPressed[0] );
    player.pos.x = max( player.size.x / 2, min( SW - player.size.x / 2, player.pos.x ) );
    
    weapon.update( dt );
  }
  
  PImage sprite;
  float speed;
  int[] keysPressed;
  Weapon weapon;
};

Player player;

class Enemy extends Moveable
{
  Enemy()
  {
  }
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
  imageMode( CENTER );
  rectMode( CENTER );
  
  player = new Player();
}

void update( float dt )
{
  player.update( dt );
  
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
    enemies[numEnemies].pos = new PVector( min( SW - player.size.x / 2, max( player.size.x / 2, random( 1 ) * SW ) ), 10 );
    enemies[numEnemies].vel = new PVector( 0, 3 );
    ++numEnemies;
    lastEnemySpawnTime = millis();
  }
}

void draw()
{
  update( 1 );
  
  background( 0, 0, 0 );
  
  player.draw();
  
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
      player.keysPressed[0] = 1;
    }
    else if (keyCode == RIGHT )
    {
      player.keysPressed[1] = 1;
    }
  }
  else
  {
    if ( key == ' ' )
    {
      player.fire();
    }
  }
}

void keyReleased() {
  if ( key == CODED )
  {
    if (keyCode == LEFT )
    {
      player.keysPressed[0] = 0;
    }
    else if (keyCode == RIGHT )
    {
      player.keysPressed[1] = 0;
    } 
  }
}
