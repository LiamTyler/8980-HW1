// String rootDir = "/home/liam/Documents/8980-HW1/";
String rootDir = "C:/Users/Tyler/Documents/8980-HW1/";

int SW = 1280;
int SH = 720;

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
    tag = 0;
  }
  
  Bullet( PVector startPos, PVector startVel, int t )
  {
    pos = startPos;
    vel = startVel;
    tag = t;
  }
  
  void draw()
  {
    fill( 255, 255, 255 );
    rect( pos.x, pos.y, size.x, size.y );
  }
  
  int tag;
};

PImage[] bulletSheet = new PImage[12];

class PlayerBullet extends Bullet
{
  PlayerBullet( PVector startPos )
  {
    super( startPos, new PVector( 0, -10 ) );
    size = new PVector( 3, 10 );
  }
  
  void draw()
  {
    stroke( 255, 255, 255 );
    fill( 255, 255, 255 );
    rect( pos.x, pos.y, size.x, size.y );
  }
};

class TractorBullet extends Bullet
{
  TractorBullet( PVector startPos )
  {
    super( startPos, new PVector( 0, -10 ), 1 );
    size = new PVector( 6, 20 );
  }
  
  void draw()
  {
    stroke( 0, 255, 242 );
    fill( 0, 255, 242 );
    rect( pos.x, pos.y, size.x, size.y );
  }
};

class EnemyBullet extends Bullet
{
  EnemyBullet( PVector startPos, int t )
  {
    super( startPos, new PVector( 0, 5 ) );
    size = new PVector( 9, 21 );
    type = t;
  }
  
  void draw()
  {
    int spriteIndex = ( customFrameCount / 2 ) % 4;
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

  void fire( PVector pos )
  {
  }
  
  void update( float dt )
  {
    for ( int i = 0; i < numBullets; ++i )
    {
      bullets[i].pos.add( PVector.mult( bullets[i].vel, dt ) );
      if ( bullets[i].pos.y < 80 || bullets[i].pos.y > SH - 40 )
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

class PlayerWeapon extends Weapon
{
  PlayerWeapon( int bt )
  {
    super( 500, 10 );
    bulletType = bt;
  }
  
  void fire( PVector pos )
  {
    int currT = millis();
    if ( currT > timeOfLastFire + fireRate )
    {
      if ( bulletType == 0 )
      {
        bullets[numBullets] = new PlayerBullet( pos );
      }
      else
      {
        bullets[numBullets] = new TractorBullet( pos );
      }
      ++numBullets;
      timeOfLastFire = currT;
    }
  }
  
  void update( float dt )
  {
    for ( int i = 0; i < numBullets; ++i )
    {
      bullets[i].pos.add( PVector.mult( bullets[i].vel, dt ) );
      if ( bullets[i].pos.y < 80 || bullets[i].pos.y > SH - 40 )
      {
        bullets[i] = bullets[numBullets - 1];
        --numBullets;
        --i;
        continue;
      }
      
      for ( int h = 0; h < numHostages; ++h )
      {
        float dx = abs( bullets[i].pos.x - hostages[h].pos.x );
        float dy = abs( bullets[i].pos.y - hostages[h].pos.y );
        
        if ( dx < ( bullets[i].size.x + hostages[h].size.x ) / 2 && dy < ( bullets[i].size.y + hostages[h].size.y ) / 2 )
        {
          if ( bullets[i].tag == 0 )
          {
            killPlayer();
            hostages[h].frameDied = customFrameCount;
            --numHostages;
          }
          else
          {
            hostages[h].frameSaved = customFrameCount;
            hostages[h].vel.x = 0;
            hostages[h].vel.y = 5;
          }
          bullets[i] = bullets[numBullets - 1];
          --numBullets;
          --h;
          break;
        }
      }
    }
  }
  
  int bulletType;
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

PImage playerSprite;

class Player extends Moveable
{
  Player()
  {
    float imgAspectRatio = 26 / 16.0;
    size           = new PVector( 50, 50 / imgAspectRatio );
    pos            = new PVector( PLAYER_START_X, PLAYER_START_Y );
    vel            = new PVector( 0, 0 );
    sprite         = playerSprite;
    speed          = 10;
    keysPressed    = new int[2];
    keysPressed[0] = 0;
    keysPressed[1] = 0;
    lastDied       = -1000;
    invincible     = false;
    
    mainWeapon    = new PlayerWeapon( 0 );
    tractorWeapon = new PlayerWeapon( 1 );
  }
  
  void fire( int bulletType ) 
  {
    if ( bulletType == 0 )
    {
      mainWeapon.fire( new PVector( pos.x, pos.y - size.y ) );
    }
    else
    {
      tractorWeapon.fire( new PVector( pos.x, pos.y - size.y ) );
    }
  }
  
  void update( float dt )
  {
    player.pos.x += dt * player.speed * ( player.keysPressed[1] - player.keysPressed[0] );
    player.pos.x  = max( player.size.x / 2, min( SW - player.size.x / 2, player.pos.x ) );
    
    invincible = customFrameCount - lastDied < 120;
    
    mainWeapon.update( dt );
    tractorWeapon.update( dt );
  }
  
  void draw()
  {
    if ( !invincible || customFrameCount / 3 % 2 == 0 )
    {
      tint( 0, 255, 0 );
      image( playerSprite, pos.x, pos.y, size.x, size.y );
    }
    
    stroke( 255, 0, 0 );
    mainWeapon.draw();
    tractorWeapon.draw();
  }
  
  PImage sprite;
  float speed;
  int[] keysPressed;
  int lastDied;
  boolean invincible;
  Weapon mainWeapon;
  Weapon tractorWeapon;
};

class Hostage extends Moveable
{
  Hostage()
  {
    frameDied  = 0;
    frameSaved = 0;
  }
  void draw()
  {
    if ( frameDied != 0 )
    {
      if ( customFrameCount - frameDied < 30 )
      {
        image( enemyDeathSprite, pos.x, pos.y, size.x, size.y );
      }
      else
      {
        return;
      }
    }
    else
    {
      if ( frameSaved == 0 || customFrameCount / 3 % 2 == 0)
      {
        image( playerSprite, pos.x, pos.y, size.x, size.y );
      }
    }
  }
  
  int frameDied;
  int frameSaved;
};

Player player;

void killPlayer()
{
  --playerLives;
  player.pos.x = PLAYER_START_X;
  player.pos.y = PLAYER_START_Y;
  player.lastDied = customFrameCount;
}

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
    type      = t;
    frameDied = 0;
    frameTractorBeamed = 0;
    weapon    = new EnemyWeapon( type );
  }
  
  EnemyWeapon weapon;
  int type;
  int frameDied;
  int frameTractorBeamed;
};

int ENEMY_WIDTH        = 5;
int ENEMY_HEIGHT       = 1;
int TOTAL_ENEMIES      = ENEMY_WIDTH * ENEMY_HEIGHT;
Enemy[] enemies        = new Enemy[TOTAL_ENEMIES];
float enemySpeed       = .3;
PImage enemyDeathSprite;

int numHostages    = ENEMY_WIDTH;
Hostage[] hostages = new Hostage[numHostages];

int customFrameCount = 0;
boolean paused = false;
PFont pixelFont;

int playerLives = 3;
int score       = 0;

int PLAYER_START_X = SW / 2;
int PLAYER_START_Y = SH - 50;

boolean[] columnFired = new boolean[ENEMY_WIDTH];
boolean fireValid( int r, int c )
{
  if ( columnFired[c] )
  {
    return false;
  }
  
  for ( int rr = r + 1; rr < ENEMY_HEIGHT; ++rr )
  {
    if ( enemies[rr * ENEMY_WIDTH + c].frameDied == 0 )
    {
      return false;
    }
  }
  
  return true;
}

int hostagesSaved = 0;

boolean frameMoved = false;
void setup()
{
  size( 100, 100 );
  surface.setSize( SW, SH );
  frameRate( 60 );
  imageMode( CENTER );
  rectMode( CENTER );
  
  pixelFont = createFont( "LCD_Solid.ttf", 24 );
  
  player = new Player();
  
  playerSprite     = loadImage( rootDir + "assets/player_sprite.png" );
  enemyDeathSprite = loadImage( rootDir + "assets/enemy_death_sprite.png" );
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
  
  for( int r = 0; r < ENEMY_HEIGHT; ++r )
  {
    for ( int c = 0; c < ENEMY_WIDTH; ++c )
    {
      int i = r * ENEMY_WIDTH + c;
      enemies[i]      = new Enemy( r % 3 );
      enemies[i].pos  = new PVector( 40 * c, 200 + r * 40 );
      enemies[i].vel  = new PVector( enemySpeed, 0 );
      enemies[i].size = new PVector( 25, 25 );
    }
  }
  for ( int i = 0; i < ENEMY_WIDTH; ++i )
  {
    hostages[i]      = new Hostage( );
    hostages[i].pos  = new PVector( 40 * i, 160 );
    hostages[i].vel  = new PVector( enemySpeed, 0 );
    hostages[i].size = new PVector( 25, 15 );
  }
}

void update( float dt )
{
  player.update( dt );
  
  for ( int i = 0; i < numHostages; ++i )
  {
    hostages[i].pos.add( PVector.mult( hostages[i].vel, dt ) );
    if ( hostages[i].pos.x >= SW )
    {
      --playerLives;
      --numHostages;
      hostages[i] = hostages[numHostages];
    }
    if ( hostages[i].pos.y > PLAYER_START_Y )
    {
      --numHostages;
      ++hostagesSaved;
      score += 100;  
      hostages[i] = hostages[numHostages];
    }
  }
  
  
  for ( int i = 0; i < ENEMY_WIDTH; ++i )
  {
    columnFired[i] = false;
  }
  
  for( int r = 0; r < ENEMY_HEIGHT; ++r )
  {
    for ( int c = 0; c < ENEMY_WIDTH; ++c )
    {
      int i = r * ENEMY_WIDTH + c;
      if ( enemies[i].frameDied == 0 && enemies[i].frameTractorBeamed != 0 && customFrameCount / 20 % 2 == 0 )
      {
        enemies[i].vel = PVector.sub( player.pos, enemies[i].pos );
        enemies[i].vel.y += 1; // hack to make sure it never flies horizontally
        enemies[i].vel.normalize();
        enemies[i].vel.mult( 10 );
      }
      
      enemies[i].pos.add( PVector.mult( enemies[i].vel, dt ) );
      enemies[i].weapon.update( dt );
      
      if ( enemies[i].frameDied != 0 )
      {
        continue;
      }
      
      if ( enemies[i].pos.x >= SW || enemies[i].pos.y > PLAYER_START_Y )
      {
        enemies[i].vel = new PVector( 0, 0 );
        enemies[i].frameDied = customFrameCount;
        // i = killEnemy( i );
      }
      
      if ( random( 1 ) < 0.0055 && fireValid( r, c) )
      {
        float x = enemies[i].pos.x + 1;
        float y = enemies[i].pos.y + enemies[i].size.y / 2;
        enemies[i].weapon.fire( new PVector( x, y ) );
        columnFired[c] = true;
      }
    }
  }
  
  for ( int enemyIndex = 0; enemyIndex < TOTAL_ENEMIES; ++enemyIndex )
  {
    Enemy e = enemies[enemyIndex];
    if ( e.frameDied != 0 )
    {
      continue;
    }
    
    for ( int bulletIndex = 0; bulletIndex < player.mainWeapon.numBullets; ++bulletIndex )
    {
      Bullet b = player.mainWeapon.bullets[bulletIndex];
      float dx = abs( b.pos.x - e.pos.x );
      float dy = abs( b.pos.y - e.pos.y );
      
      if ( dx < ( b.size.x + e.size.x ) / 2 && dy < ( b.size.y + e.size.y ) / 2 )
      {        
        e.frameDied = customFrameCount;
        score += 10;
        
        player.mainWeapon.destroyBullet( bulletIndex );
        break;
      }
    }
    
    for ( int bulletIndex = 0; bulletIndex < player.tractorWeapon.numBullets; ++bulletIndex )
    {
      Bullet b = player.tractorWeapon.bullets[bulletIndex];
      float dx = abs( b.pos.x - e.pos.x );
      float dy = abs( b.pos.y - e.pos.y );
      
      if ( dx < ( b.size.x + e.size.x ) / 2 && dy < ( b.size.y + e.size.y ) / 2 )
      {
        e.frameTractorBeamed = customFrameCount;
        e.vel = PVector.sub( player.pos, e.pos );
        e.vel.normalize();
        e.vel.mult( 10 );
        player.tractorWeapon.destroyBullet( bulletIndex );
        break;
      }
    }
    
    if ( player.invincible )
    {
      continue;
    }
    
    float p_dx = player.pos.x - e.pos.x;
    float p_dy = player.pos.y - e.pos.y;
    if ( p_dx < player.size.x / 2 + e.size.x / 2 && p_dy < player.size.y / 2 + e.size.y / 2 )
    {
      killPlayer();
      e.frameDied = customFrameCount;
      e.vel.x = 0;
      e.vel.y = 0;
      break;
    }
    
    // enemy bullets
    for ( int bulletIndex = 0; bulletIndex < e.weapon.numBullets; ++bulletIndex )
    {
      Bullet b = e.weapon.bullets[bulletIndex];
      float dx = abs( b.pos.x - player.pos.x );
      float dy = abs( b.pos.y - player.pos.y );
      
      if ( dx < ( b.size.x + player.size.x ) / 2 && dy < ( b.size.y + player.size.y ) / 2 )
      {
        e.weapon.destroyBullet( bulletIndex );
        killPlayer();
        break;
      }
    }
  }
}

void draw()
{
  if(!frameMoved){
    surface.setLocation(100, 100);
    frameMoved = true;
  }
  if ( playerLives <= 0 )
  {
    background( 0, 0, 0 );
    fill( 255, 255, 255 );
    textFont( pixelFont, 72 );
    textAlign( CENTER, CENTER );
    text( "GAME OVER", SW / 2, SH / 2 );
    return;
  }
  if ( numHostages == 0 )
  {
    background( 0, 0, 0 );
    fill( 255, 255, 255 );
    textFont( pixelFont, 72 );
    textAlign( CENTER, CENTER );
    text( "YOU WIN!!!", SW / 2, SH / 2 );
    return;
  }
  
  if ( !paused )
  {
    update( 1 );
    ++customFrameCount;
  }
  
  background( 0, 0, 0 );
  
  textAlign( LEFT, TOP );
  fill( 255, 255, 255 );
  textFont( pixelFont, 24 );
  text( "SCORE <1>  HI-SCORE SCORE <2>", 100, 5 );
  
  // display leading 0's in score to always keep it at 4 digits
  int numDigits = max( 0, int( log( score + 0.1 ) / log( 10 ) ) );
  int scoreTextX = 130;
  for ( int i = 0; i < 3 - numDigits; ++i )
  {
    text( "0", scoreTextX, 40 );
    scoreTextX += 15;
  }
  // actual score
  text( str( score ), scoreTextX, 40 );
  // highscore (always 0000)
  text( "0000", 280, 40 );
  
  stroke( 0, 255, 0 );
  line( 0, SH - 30, SW, SH - 30 );
  text( str( playerLives ), 100, SH - 25 );
  text( "CREDIT  00", SW - 200, SH - 25 );
  tint( 0, 255, 0 );
  for ( int i = 0; i < playerLives - 1; ++i )
  {
    image( playerSprite, 150 + i * 45, SH - 15, 35, 25 );
  }
  
  tint( 0, 0, 255 );
  image( playerSprite, 325, SH - 15, 35, 25 );
  text( "HOSTAGES SAVED: " + str( hostagesSaved ) + "/" + str( ENEMY_WIDTH ), 350, SH - 25 );
  tint( 0, 0, 255 );
  
  //for ( int i = 0; i < ENEMY_WIDTH - numH; ++i )
  //{
  //  image( playerSprite, 150 + i * 45, SH - 15, 35, 25 );
  //}  

  player.draw();
  
  tint( 0, 0, 255 );
  for ( int i = 0; i < numHostages; ++i )
  {
    hostages[i].draw();
  }
  
  noTint();
  int spriteIndex = ( customFrameCount / 10 ) % 2;
  for ( int i = 0; i < ENEMY_WIDTH * ENEMY_HEIGHT; ++i )
  {
    if ( enemies[i].frameDied != 0 )
    {
      if ( customFrameCount - enemies[i].frameDied < 30 )
      {
        image( enemyDeathSprite, enemies[i].pos.x, enemies[i].pos.y, enemies[i].size.x, enemies[i].size.y );
      }
      else
      {
        continue;
      }
    }
    else
    {
      EnemySprite s = enemySprites[enemies[i].type];
      image( s.imgs[spriteIndex], enemies[i].pos.x, enemies[i].pos.y, enemies[i].size.x, enemies[i].size.y );
    }
  }
  
  for ( int i = 0; i < ENEMY_WIDTH * ENEMY_HEIGHT; ++i )
  {
    enemies[i].weapon.draw();
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
      player.fire( 0 );
    }
    else if ( key == 't' )
    {
      player.fire( 1 );
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
