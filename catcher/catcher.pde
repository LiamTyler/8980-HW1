String rootDir = "/home/liam/Documents/8980-HW1/";

int SW = 800;
int SH = 600;

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
  
  void destroyBullet( int index )
  {
    bullets[index] = bullets[--numBullets];    
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
    noTint();
    image( sprite, pos.x, pos.y, size.x, size.y );
    
    weapon.draw();
  }
  
  PImage sprite;
  float speed;
  int[] keysPressed;
  Weapon weapon;
};

Player player;

class Sprite
{
  Sprite( PImage image )
  {
    img = image;
  }
  
  PImage img;
};

class EnemySprite
{
  EnemySprite( )
  {
    imgs = new PImage[2];
  }
  
  PImage[] imgs;
};

EnemySprite[] enemySprites = new EnemySprite[3];

class Enemy extends Moveable
{
  Enemy( int t )
  {
    type = t;
  }
  
  int type;
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

boolean paused = false;

void setup()
{
  size( 100, 100 );
  surface.setSize( SW, SH );
  frameRate( 60 );
  imageMode( CENTER );
  rectMode( CENTER );
  
  player = new Player();
  
  PImage img;
  enemySprites[0] = new EnemySprite();
  enemySprites[1] = new EnemySprite();
  enemySprites[2] = new EnemySprite();
  img = loadImage( rootDir + "assets/enemy1_sheet.png" );
  enemySprites[0].imgs[0] = img.get( 0,  0, 16, 16 );
  enemySprites[0].imgs[1] = img.get( 33, 0, 16, 16 );
  img = loadImage( rootDir + "assets/enemy2_sheet.png" );
  enemySprites[1].imgs[0] = img.get( 0,  0, 22, 16 );
  enemySprites[1].imgs[1] = img.get( 33, 0, 22, 16 );
  img = loadImage( rootDir + "assets/enemy3_sheet.png" );
  enemySprites[2].imgs[0] = img.get( 0,  0, 24, 16 );
  enemySprites[2].imgs[1] = img.get( 32, 0, 24, 16 );
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
    enemies[numEnemies]     = new Enemy( (int) random( 3 ) );
    enemies[numEnemies].pos = new PVector( min( SW - player.size.x / 2, max( player.size.x / 2, random( 1 ) * SW ) ), 10 );
    enemies[numEnemies].vel = new PVector( 0, 1 );
    ++numEnemies;
    lastEnemySpawnTime = millis();
  }
  
  for ( int enemyIndex = 0; enemyIndex < numEnemies; ++enemyIndex )
  {
    Enemy e  = enemies[enemyIndex];
    for ( int bulletIndex = 0; bulletIndex < player.weapon.numBullets; ++bulletIndex )
    {
      Bullet b = player.weapon.bullets[bulletIndex];
      float dx = abs( b.pos.x - e.pos.x );
      float dy = abs( b.pos.y - e.pos.y );
      
      if ( dx < ( b.size.x + e.size.x ) / 2 && dy < ( b.size.y + e.size.y ) / 2 )
      {
        enemyIndex = killEnemy( enemyIndex );
        
        player.weapon.destroyBullet( bulletIndex );
        --bulletIndex;
        break;
      }
    }
  }
}

void draw()
{
  update( 1 );
  
  background( 0, 0, 0 );
  
  player.draw();
  
  int spriteIndex = ( frameCount / 30 ) % 2;
  for ( int i = 0; i < numEnemies; ++i )
  {
    EnemySprite s = enemySprites[enemies[i].type];
    // tint( s.c );
    
    image( s.imgs[spriteIndex], enemies[i].pos.x, enemies[i].pos.y, enemies[i].size.x, enemies[i].size.y );
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
    else if ( key == 'p' )
    {
      paused = !paused;
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
