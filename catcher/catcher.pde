// String rootDir = "/home/liam/Documents/8980-HW1/";
String rootDir = "C:/Users/Tyler/Documents/8980-HW1/";

int SW = 640;
int SH = 480;

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
    fill( 255, 255, 255 );
    rect( pos.x, pos.y, size.x, size.y );
  }
};

PImage[] bulletSheet = new PImage[12];

class PlayerBullet extends Bullet
{
  PlayerBullet( PVector startPos )
  {
    super( startPos, new PVector( 0, -10 ) );
    size = new PVector( 9, 21 );
  }
  
  void draw()
  {
    fill( 255, 0, 0 );
    rect( pos.x, pos.y, size.x, size.y );
  }
};

class EnemyBullet extends Bullet
{
  EnemyBullet( PVector startPos, int t )
  {
    super( startPos, new PVector( 0, -3 ) );
    size = new PVector( 9, 21 );
    type = t;
  }
  
  void draw()
  {
    int spriteIndex = 3 - ( frameCount / 5 ) % 4;
    image( bulletSheet[4 * type + spriteIndex], pos.x, pos.y, size.x, size.y );
  }
  
  int type;
};

class Weapon
{
  Weapon( int rate, int maxBullets )
  {
    fireRate       = rate;
    bullets        = new Bullet[maxBullets];
    numBullets     = 0;
    timeOfLastFire = 0;
  }
  
  void abstract fire( PVector pos );
  
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

class PlayerWeapon extends Weapon
{
  PlayerWeapon()
  {
    super( 500, 10 );
  }
  
  void fire( PVector pos )
  {
    int currT = millis();
    if ( currT > timeOfLastFire + fireRate )
    {
      bullets[numBullets] = new PlayerBullet( pos );
      ++numBullets;
      timeOfLastFire = currT;
    }
  }
};

class EnemyWeapon extends Weapon
{
  EnemyWeapon( int t )
  {
    super( 500, 5 );
    type = t;
  }
  
  void fire( PVector pos )
  {
    int currT = millis();
    if ( currT > timeOfLastFire + fireRate )
    {
      bullets[numBullets] = new EnemyBullet( pos, type );
      ++numBullets;
      timeOfLastFire = currT;
    }
  }
  
  int type;
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
    
    weapon = new EnemyWeapon( 0 );
    // weapon = new PlayerWeapon();
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

void setup()
{
  size( 100, 100 );
  surface.setSize( SW, SH );
  frameRate( 60 );
  imageMode( CENTER );
  rectMode( CENTER );
  
  PImage img;
  img = loadImage( rootDir + "assets/bullets1_sheet.png" );
  bulletSheet[0] = img.get( 0,  0, 3, 7 );
  bulletSheet[1] = img.get( 5,  0, 3, 7 );
  bulletSheet[2] = img.get( 10, 0, 3, 7 );
  bulletSheet[3] = img.get( 15, 0, 3, 7 );
  img = loadImage( rootDir + "assets/bullets2_sheet.png" );
  bulletSheet[4] = img.get( 0,  0, 3, 7 );
  bulletSheet[5] = img.get( 5,  0, 3, 7 );
  bulletSheet[6] = img.get( 10, 0, 3, 7 );
  bulletSheet[7] = img.get( 15, 0, 3, 7 );
  img = loadImage( rootDir + "assets/bullets3_sheet.png" );
  bulletSheet[8]  = img.get( 0,  0, 3, 7 );
  bulletSheet[9]  = img.get( 5,  0, 3, 7 );
  bulletSheet[10] = img.get( 10, 0, 3, 7 );
  bulletSheet[11] = img.get( 15, 0, 3, 7 );
  
  
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
  
  fill( 255, 255, 255 );
  for ( int i = 0; i < numEnemies; ++i )
  {
    // rect( enemies[i].pos.x, enemies[i].pos.y, enemies[i].size.x, enemies[i].size.y );
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
