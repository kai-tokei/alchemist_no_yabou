class CatchEffect {
    PVector world_pos;
    PVector screen_pos;

    // 変化率
    float duration = 0.5f;
    float duration_speed = 0.05f;

    // 透明度・大きさの変化速度
    float alpha_rate;
    float size_rate;

    // 透明度
    float alpha = 128f;

    // 大きさ
    int current_size = 400;

    // 目標色
    int target_r = 0;
    int target_g = 100;
    int target_b = 255;

    boolean is_alive = true;

    CatchEffect (PVector world_pos, int meteor_type) {
        this.world_pos = world_pos;
        this.alpha_rate = random(6, 8);
        this.size_rate = alpha_rate;

        // 種類に応じて色変える
        switch (meteor_type) {
            case 1:
                this.target_r = 255;
                this.target_g = 0;
                this.target_b = 0;
                break;
            case 2:
                this.target_r = 0;
                this.target_g = 255;
                this.target_b = 0;
                break;
            case 0:
                this.target_r = 0;
                this.target_g = 100;
                this.target_b = 255;
                break;
        }
    }

    void update(Camera camera) {
        // 座標計算
        screen_pos = world_to_screen(this.world_pos, camera);

        // 遷移率をだんだん変化させる
        this.duration += this.duration_speed;

        // 透明度・大きさを下げる
        this.alpha -= this.alpha_rate;
        this.current_size -= this.size_rate;

        if (this.alpha <= 0 || this.current_size <= 0) {
            this.is_alive = false;
        }
    }

    void draw() {
        if (!is_alive) return ;
        // デカルト系から画面系へ変換する
        screen_pos = world_to_screen(this.world_pos, camera);

        // カメラの視野角に入っていたら、描画する
        if (screen_pos != null) {
            noStroke();

            // 色を線型補完して、変化させる
            float r = lerp(255, target_r, this.duration);
            float g = lerp(255, target_g, this.duration);
            float b = lerp(255, target_b, this.duration);

            fill(r, g, b, this.alpha);
            ellipse(screen_pos.x, screen_pos.y, this.current_size, this.current_size);
        }
    }
}
