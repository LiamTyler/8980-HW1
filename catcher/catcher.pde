String rootDir = "/home/liam/Documents/8980-HW1/";

int SW = 800;
int SH = 400;

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
    super( startPos, new PVector( 0, -1 ) );
    size = new PVector( 6, 12 );
    col = color( 255, 0, 0 );
  }
};

class Weapon
{
  Weapon()
  {
    fireRate       = 100;
    bullets        = new Bullet[100];
    numBullets     = 0;
    timeOfLastFire = 0;
  }
  
  void fire( PVector pos )
  {
    int currT = millis();
    if ( currT > timeOfLastFire + fireRate )
    {
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
      if ( bullets[i].pos.y < 0 )
      {
        bullets[i] = bullets[numBullets - 1];
        --numBullets;
        --i;
      }
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
  
  void draw()
  {
    image( sprite, pos.x, pos.y, size.x, size.y );
    
    weapon.draw();
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

int killEnemy( int index )
{
  enemies[index] = enemies[numEnemies - 1];
  --numEnemies;
  return index - 1;
}

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
      i = killEnemy( i );
    }
  }
  
  if ( millis() - lastEnemySpawnTime > 100 && random( 1 ) < .1 && numEnemies < MAX_ENEMIES )
  {
    enemies[numEnemies]     = new Enemy();
    enemies[numEnemies].pos = new PVector( min( SW - player.size.x / 2, max( player.size.x / 2, random( 1 ) * SW ) ), 10 );
    enemies[numEnemies].vel = new PVector( 0, 1 );
    ++numEnemies;
    lastEnemySpawnTime = millis();
  }
  
  for ( int enemyIndex = 0; enemyIndex < numEnemies; ++enemyIndex )
  {
    for ( int bulletIndex = 0; bulletIndex < player.weapon.numBullets; ++bulletIndex )
    {
      Enemy e  = enemies[enemyIndex];
      Bullet b = player.weapon.bullets[bulletIndex];
      float dx = abs( b.pos.x - e.pos.x );
      float dy = abs( b.pos.y - e.pos.y );
      
      if ( dx < ( b.size.x + e.size.x ) / 2 && dy < ( b.size.y + e.size.y ) / 2 )
      {
        println( "Enemy pos = ", e.pos, ", bullet pos = ", b.pos );
        enemyIndex = killEnemy( enemyIndex );
        while ( true );
      }
    }
  }
}

void draw()
{
  update( 1 );
  
  background( 0, 0, 0 );
  
  player.draw();
  
  fill( color( 255, 255, 255 ) );
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
