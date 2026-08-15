class Meteor {
    PVector world_pos;
    PVector screen_pos;
    PVector rot_vec;  // 2次元にする予定。x軸, y軸の回転速度
    int size;
    float speed; // 流れ星の大きさ
    boolean is_alive = true;

    // 現在の角度を保持する変数
    float current_yaw_rad;
    float current_pitch_rad;
    float radius;

    // 0 = normal(blue), 1 = too hot(red), 2 = double point(green)
    int meteor_type;

    Meteor (PVector world_pos, PVector rot_vec, float speed, int size, int meteor_type) {
        this.world_pos = world_pos;
        this.rot_vec = rot_vec.normalize();
        this.speed = speed;
        this.size = size;
        this.meteor_type = meteor_type;

        // 原点からの距離
        this.radius = world_pos.mag();

        float xz_dist = sqrt(
            this.world_pos.x * this.world_pos.x +
            this.world_pos.z * this.world_pos.z
        );
        this.current_pitch_rad = atan2(this.world_pos.y, xz_dist);
        this.current_yaw_rad = atan2(this.world_pos.x, xz_dist);
    }

    void update(TrailManager trail_manager) {
        // 角度を直接更新する（度数法から弧度法に変換して足す/引く）
        // Y軸中心の回転（Yaw）
        this.current_yaw_rad += radians(this.rot_vec.y * this.speed);

        // 高さを下げる回転（Pitch）
        this.current_pitch_rad -= radians(this.rot_vec.x * this.speed);

        // 更新された角度から、新しい世界座標（3D位置）を計算する（球座標系から直交座標系への変換）
        float cos_p = cos(this.current_pitch_rad);
        this.world_pos.x = this.radius * cos_p * sin(this.current_yaw_rad);
        this.world_pos.y = this.radius * sin(this.current_pitch_rad);
        this.world_pos.z = this.radius * cos_p * cos(this.current_yaw_rad);

        // 現在の位置に新しい残像を追加
        trail_manager.add_trail(this.world_pos, this.size, this.meteor_type);

        // pitchが0以下（地平線以下）ならば、消滅させる
        if (this.current_pitch_rad <= 0.0f) {
            this.is_alive = false;
        }
    }

    void draw(Camera camera) {
        screen_pos = world_to_screen(this.world_pos, camera);
        if (screen_pos != null){
            noStroke();
            fill(255);
            ellipse(screen_pos.x, screen_pos.y, this.size, this.size);
        }
    }
}
