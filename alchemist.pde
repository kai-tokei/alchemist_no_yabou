// コールバック用のインターフェース
interface GrispingCallback {
    void onGrisping(PVector world_pos, int meteor_type);
}

// 星のデータを格納するリスト
ArrayList<StarData> star_list = new ArrayList<StarData>();

// 0 = title, 1 = story, 2 = game, 3 = gameover
int scene = 0;

// オブジェクト群
MeteorManager meteor_manager;
CatchEffectManager catch_effect_manager;
Camera camera;
Moon moon;
Hand hand;
ScoreBoard score_board;

// 現在のカメラのpitch
float current_pitch_deg = 0.0f;

// 投げれ星の生成タイマー管理用変数
int last_meteor_time = 0; // 最後に流れ星が生成された時刻（ms）
int next_meteor_interval = 1000; // 次に生成されるまでの間隔（初期値）

// コントローラー用変数
boolean keyLeft = false, keyRight = false, keyUp = false, keyDown = false;

PImage img_title;

void setup() {
    // window周りの設定
    size(640, 480);
    surface.setTitle("占星術師の野望");
    surface.setResizable(true);

    pixelDensity(1);

    star_list = generate_stars(2500, 0.7);

    // カメラの定義（初期段階では、すべて0で設定）
    camera = new Camera(
        new PVector(0.0, 0.0, 0.0), 60.0f);

    moon = new Moon(new PVector(0, 800, 1000), 0.3f);
    hand = new Hand();
    meteor_manager = new MeteorManager();
    catch_effect_manager = new CatchEffectManager();
    score_board = new ScoreBoard();

    // ゲーム開始時を最初のタイマー基準点にする
    last_meteor_time = millis();

    img_title = loadImage("images/title.png");
}


void keyPressed() {
    //if (key == ' ') hand.is_grisping = true;
    if (key == ' ') hand.start_grisp();

    if (key == CODED) {
        if (keyCode == LEFT)  keyLeft = true;
        if (keyCode == RIGHT) keyRight = true;
        if (keyCode == DOWN)    keyUp = true;
        if (keyCode == UP)  keyDown = true;
    }
}

void keyReleased() {
    //if (key == ' ') hand.is_grisping = false;

    if (key == CODED) {
        if (keyCode == LEFT)  keyLeft = false;
        if (keyCode == RIGHT) keyRight = false;
        if (keyCode == DOWN)    keyUp = false;
        if (keyCode == UP)  keyDown = false;
    }
}

void draw() {
    // 一定時間ごとに流れ星を自動生成する
    int current_time = millis();
    if (current_time - last_meteor_time >= next_meteor_interval) {
        // 流れ星の初期位置と速度ベクトルをランダムに設定
        PVector spawn_pos = get_world_vector(random(0, 360), random(-85, -90));
        PVector spawn_vel = new PVector(random(0.1f, 0.4f), random(0.3f, 0.6f));

        // 流れ星を生成する
        meteor_manager.add_meteor(spawn_pos, spawn_vel, int(random(20))%3);

        // タイマーのリセットと、次の生成間隔をランダムに決定する
        last_meteor_time = current_time;
        next_meteor_interval = (int)random(200, 800);
    }

    // どのキーが押されているかによって回転量を決める
    float delta_rotation_yaw = 0;
    float delta_rotation_pitch = 0;

    // キー入力の感度（押し続けたときの回転スピード）
    float key_sensitivity = 0.8f;

    // カメラの操作
    if (keyLeft) {
        delta_rotation_yaw = -key_sensitivity;
    }
    if (keyRight) {
        delta_rotation_yaw = key_sensitivity;
    }

    // 上下の回転（ピッチ）は制限をかける
    if (keyDown) {
        float next_pitch = current_pitch_deg - (key_sensitivity);
        // -90度（真上）より上に行かないように制限
        if (next_pitch >= -80.0f) {
            delta_rotation_pitch = -key_sensitivity;
            current_pitch_deg = next_pitch;
        }
    }
    if (keyUp) {
        float next_pitch = current_pitch_deg + (key_sensitivity);
        // 90度（真下）より下に行かないように制限
        if (next_pitch <= 10.0f) {
            delta_rotation_pitch = key_sensitivity;
            current_pitch_deg = next_pitch;
        }
    }

    // 回転量を四元数に落とし込む
    Quaternion rot_yaw = angle_to_q(0, delta_rotation_yaw, 0);
    Quaternion rot_pitch = angle_to_q(delta_rotation_pitch, 0, 0);

    // カメラを回転
    /*
        クォータニオンの掛け算（multiply_q(A, B)）は、
        「左側（A）にかけるか、右側（B）にかけるか」で、
        世界の軸で回るか、自分の軸で回るかが変わるという性質を持っている
    */
    camera.orientation = multiply_q(rot_yaw, camera.orientation);
    camera.orientation = multiply_q(camera.orientation, rot_pitch);

    background(0);

    // 全ての星の画面座標を一括計算する
    calculate_stars(star_list, camera);

    // 流れ星の計算
    meteor_manager.update(hand, new GrispingCallback() {
        @Override
        public void onGrisping(PVector world_pos, int meteor_type) {
            catch_effect_manager.add_catch_effect(world_pos, meteor_type);

            score_board.add(meteor_type);
        }
    });
    hand.update();
    catch_effect_manager.update(camera);
    score_board.update();

    draw_stars(star_list, 1.5, 255, 2.512f);
    meteor_manager.draw(camera);
    moon.draw(camera);
    catch_effect_manager.draw();
    hand.draw();
    score_board.draw();

    tint(255, 255);
}
