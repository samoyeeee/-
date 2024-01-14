import processing.core.PApplet;

public class Main extends PApplet {
    Player player;
    Enemy[] enemies;
    Rocket[] rockets;
    Star[] stars;
    Obstacle[] obstacles; // 新增：固定障碍物
    int gameState = 0;
    float startTime;
    float endTime;
    float highScore = 0;
    int lives = 3;
    boolean levelCompleted = false;
    boolean bossSpawned = false;
    Boss boss;
     float[] levelTimes;  // 用于记录每一关的时间
    int currentLevel = 0; // 当前关卡
    float currentGameTime = 0;



    public static void main(String[] args) {
        PApplet.main("Main");
    }

    public void settings() {
        size(800, 400);
    }

    public void setup() {
        player = new Player(50, height / 2);
        noCursor();
        frameRate(60);

        rockets = new Rocket[1];
        rockets[0] = new Rocket(random(width), random(50, height - 50));

        // 初始放置一些敌人
        spawnEnemies(5);

        // 初始放置一些黄色星星
        spawnStars(2);
       

        // 新增：生成固定障碍物
        spawnObstacles(5);
        levelTimes = new float[6];  // 假设游戏有 5 关，索引从 0 开始
    }

  
   

    public void draw() {
        background(231, 233, 211);
        stroke(43, 37, 21);
        line(0, height - 20, width, height - 20);
        noStroke();
        fill(202, 205, 128);
        rect(0, height - 19, width, height);
        
        currentGameTime = millis() / 1000 - startTime;
    fill(0);
    textSize(16);
    textAlign(CENTER, CENTER);
    text("Current Time: " + round(currentGameTime) + "s", width * 0.1, height * 0.1);


        // 新增：显示固定障碍物
        if (obstacles != null) {
            for (Obstacle obstacle : obstacles) {
                obstacle.display();
            }
        }

        if (gameState == 0) {
            player.update();
            player.display();

            if (!levelCompleted) {
                if (frameCount % 60 == 0) {
                    spawnEnemies(3);
                }

                if (!bossSpawned && frameCount % 800 == 0) {
                    spawnBoss();
                }

                handleEnemies();

                if (bossSpawned) {
                    boss.update();
                    boss.display();

                    if (player.checkCollision(boss)) {
                        loseLife();
                    }

                    if (boss.offscreen()) {
                        bossSpawned = false;
                        levelCompleted = true;
                    }
                }

                handleRockets();
                handleStars();

                // 新增：检查与固定障碍物的碰撞
                checkObstacleCollision();

                if (player.posx > width - 20 && !bossSpawned) {
                    levelCompleted = true;
                    endGame();
                }
            } else {
                fill(255, 0, 0);
                textSize(32);
                textAlign(CENTER, CENTER);
                text("Level Completed! Click to Next Level", width * 0.5, height * 0.5);
            }
        } else if (gameState == 1) {
            fill(255, 0, 0);
            textSize(32);
            textAlign(CENTER, CENTER);
            text("Game Over! Click to Restart", width * 0.5, height * 0.5);
        }

        fill(0);
        textSize(16);
        textAlign(CENTER, CENTER);
        text("Best Time: " + round(highScore) + "s", width * 0.5, height * 0.8);
        text("Lives: " + lives, width * 0.9, height * 0.1);
    }

    public void mousePressed() {
        if (gameState == 1 || levelCompleted) {
            restartGame();
        }
    }

    void restartGame() {
        player = new Player(50, height / 2);
        enemies = null;
        rockets = new Rocket[1];
        rockets[0] = new Rocket(random(width), random(50, height - 50));
        boss = null;
        gameState = 0;
        lives = 3;
        loop();
        startTime = millis() / 1000;
        levelCompleted = false;
        bossSpawned = false;

        spawnEnemies(5);
        spawnStars(2);
        spawnObstacles(5);
    }

     void endGame() {
       gameState = 1;
    endTime = millis() / 1000;

    // 更新最高分
    float gameDuration = endTime - startTime;

    if (gameState == 1 && gameDuration > highScore) {
        highScore = gameDuration;
    }
    }



    void loseLife() {
        if (lives > 0) {
            lives--;
            if (lives == 0) {
                endGame();
            }
        }
    }

    void gainLife() {
        lives++;
    }

    void spawnEnemies(int num) {
        if (enemies == null) {
            enemies = new Enemy[num];
        } else {
            Enemy[] newEnemies = new Enemy[enemies.length + num];
            System.arraycopy(enemies, 0, newEnemies, 0, enemies.length);
            enemies = newEnemies;
        }

        for (int i = 0; i < num; i++) {
            enemies[enemies.length - num + i] = new Enemy(width, random(50, height - 50), random(2, 5));
        }
    }

    void spawnStars(int num) {
        if (stars == null) {
            stars = new Star[num];
        } else {
            Star[] newStars = new Star[stars.length + num];
            System.arraycopy(stars, 0, newStars, 0, stars.length);
            stars = newStars;
        }

        for (int i = 0; i < num; i++) {
            stars[stars.length - num + i] = new Star(width, random(50, height - 50), random(3, 6));
        }
    }

    // 新增：生成固定障碍物
    void spawnObstacles(int num) {
        obstacles = new Obstacle[num];
        for (int i = 0; i < num; i++) {
            obstacles[i] = new Obstacle(random(width), random(50, height - 50));
        }
    }

    void handleEnemies() {
        if (enemies != null) {
            for (int i = enemies.length - 1; i >= 0; i--) {
                if (enemies[i] != null) {
                    enemies[i].update();
                    enemies[i].display();

                    if (player.checkCollision(enemies[i])) {
                        loseLife();
                        enemies[i] = null;
                    }

                    if (enemies[i] != null && enemies[i].offscreen()) {
                        enemies[i] = null;
                    }
                }
            }
        }
    }

    void handleRockets() {
        if (rockets != null) {
            for (int j = rockets.length - 1; j >= 0; j--) {
                if (rockets[j] != null) {
                    rockets[j].update();
                    rockets[j].display();

                    if (player.checkCollision(rockets[j])) {
                        gainLife();
                        rockets[j] = null;
                    }

                    if (rockets[j] != null && rockets[j].offscreen()) {
                        rockets[j] = null;
                    }
                }
            }
        }
    }

    // 新增：处理黄色星星
    void handleStars() {
        if (stars != null) {
            for (int k = stars.length - 1; k >= 0; k--) {
                if (stars[k] != null) {
                    stars[k].update();
                    stars[k].display();

                    if (player.checkCollision(stars[k])) {
                        gainLife();
                        stars[k] = null;
                    }

                    if (stars[k] != null && stars[k].offscreen()) {
                        stars[k] = null;
                    }
                }
            }
        }
    }

 
void checkObstacleCollision() {
    if (obstacles != null) {
        for (Obstacle obstacle : obstacles) {
            if (obstacle != null && obstacleCollision(obstacle)) {
                loseLife(); // 如果碰到障碍物，减少一条生命
            }
        }
    }
}

boolean obstacleCollision(Obstacle obstacle) {
    // 检查玩家是否与障碍物发生碰撞
    float closestX = constrain(player.posx, obstacle.posx, obstacle.posx + 30);
    float closestY = constrain(player.posy, obstacle.posy, obstacle.posy + 80);

    // 计算玩家到障碍物中心的距离
    float distanceX = player.posx - closestX;
    float distanceY = player.posy - closestY;

    // 计算两点间的距离
    float distance = sqrt(distanceX * distanceX + distanceY * distanceY);

    // 如果距离小于半径，则发生碰撞
    return distance < 15;
}

    void spawnBoss() {
        boss = new Boss(width, height / 2, random(1, 2));
        bossSpawned = true;
    }

    class Player {
        float posx, posy;
        float speed = 5; // 新增：玩家的移动速度

        Player(float x, float y) {
            posx = x;
            posy = y;
        }

        void update() {
            // 新增：玩家左右移动
            if (keyPressed) {
                if (keyCode == LEFT) {
                    posx = max(posx - speed, 0);
                } else if (keyCode == RIGHT) {
                    posx = min(posx + speed, width);
                }
            }

            // 保持在垂直方向的移动
            posy = constrain(mouseY, 30, height - 30);
        }

        void display() {
            fill(255);
            stroke(0);
            strokeWeight(3);
            ellipse(posx, posy, 30, 30);

            // Eyes
            strokeWeight(6);
            point(posx + 5, posy - 4);
            point(posx - 5, posy - 4);

            // Hands
            strokeWeight(3);
            line(posx - 6, posy - 8, posx - 14, posy - 15);
            line(posx + 6, posy - 8, posx + 14, posy - 15);

            // Feet
            arc(posx - 3, posy + 19, 14, 14, PI, TWO_PI);
            line(posx - 9, posy + 19, posx + 3, posy + 19);
            arc(posx + 3, posy + 19, 14, 14, PI, TWO_PI);
        }

        boolean checkCollision(GameObject obj) {
            float d = dist(posx, posy, obj.posx, obj.posy);
            return d < 15;
        }
    }

    class Enemy extends GameObject {
        float speed;

        Enemy(float x, float y, float speed) {
            super(x, y);
            this.speed = speed;
        }

        void update() {
            posx -= speed;
        }

        void display() {
            fill(150, 0, 0);
            ellipse(posx, posy, 20, 20);
        }

        boolean offscreen() {
            return posx < -10;
        }
    }

    class Rocket extends GameObject {
        float speed;

        Rocket(float x, float y) {
            super(x, y);
            speed = random(6, 10);
        }

        void update() {
            posx += speed;
        }

        void display() {
            fill(255, 255, 0);
            noStroke();
            ellipse(posx, posy, 15, 15);
        }

        boolean offscreen() {
            return posx > width + 10;
        }
    }

    class Boss extends Enemy {
      float health;
        float bossSpeed = 8;  // 新增：Boss 移动速度

        Boss(float x, float y, float speed) {
            super(x, y, speed);
            this.health = 100;
        }

        @Override
        void display() {
            fill(0, 0, 200);
            ellipse(posx, posy, 60, 60);  // 修改：Boss 更大
        }

        @Override
        void update() {
            super.update();

            // 新增：让 Boss 上下移动
            posy += sin(frameCount * 0.1) * 5;

            // Boss 移动速度更快
            posx -= bossSpeed;
        }
    }   

    class GameObject {
        float posx, posy;

        GameObject(float x, float y) {
            posx = x;
            posy = y;
        }
    }

    // 新增：黄色星星类
    class Star extends GameObject {
        float speed;

        Star(float x, float y, float speed) {
            super(x, y);
            this.speed = speed;
        }

        void update() {
            posx -= speed;
        }

        void display() {
            fill(255, 255, 0);
            stroke(255);
            strokeWeight(2);
            ellipse(posx, posy, 25, 25);
            line(posx - 10, posy, posx + 10, posy);
            line(posx, posy - 10, posx, posy + 10);
        }

        boolean offscreen() {
            return posx < -10;
        }
    }

    // 新增：固定障碍物类
    class Obstacle extends GameObject {
        Obstacle(float x, float y) {
            super(x, y);
        }

        void display() {
            fill(100, 100, 100);
            rect(posx, posy, 30, 80);
        }
void handleCollision() {
    // 处理与玩家碰撞的逻辑，例如减少一条生命
    loseLife();
}

        boolean checkPlayerCollision(Player player) {
            // 新增：检查玩家是否在障碍物区域内，如果是则返回 true
            return player.posx + 15 > posx && player.posx - 15 < posx + 30 && player.posy > posy && player.posy < posy + 80;
        }
    }
}
