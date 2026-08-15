class Trail {
    PVector world_pos;
    float current_size; // 現在の大きさ
    float alpha_rate;  // 透明になる早さ
    float alpha = 255;
    float size_rate; // 小さくなる早さ
    boolean is_alive; // 存在しているかどうか
    float color_blend = 0.0f; // 色が白から青へ変化する進行度(0.0 = white, 1.0 = blue);
    float color_shift_speed = 0.05f;

    int target_r = 0;
    int target_g = 100;
    int target_b = 255;

    Trail (PVector world_pos, float start_size, int trail_type) {
        this.world_pos = world_pos.copy();
        this.current_size = start_size;
        this.is_alive = true;

        // 種類に応じて色変える
        switch (trail_type) {
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
            case 0 :
                this.target_r = 0;
                this.target_g = 100;
                this.target_b = 255;
                break;
        }

        // 透明になる速さや大きさの傾きを設定
        this.alpha_rate = random(8, 15);
        this.size_rate = random(0.1, 0.2);
    }

    // 目標色を設定
    void set_target_color(int r, int g, int b) {
        this.target_r = r;
        this.target_g = g;
        this.target_b = b;
    }

    void update() {
        // 透明度を上げつつだんだん小さくすることで、軌跡が消えていく感を出す
        this.alpha -= this.alpha_rate;
        this.current_size -= this.size_rate;

        // 色のlerp用変数を制御（少しずつ遷移させる）
        this.color_blend += this.color_shift_speed;
        if (this.color_blend > 1.0f) this.color_blend = 1.0f;

        // 完全に透明になった、あるいは大きさが0になったら削除
        if (this.alpha <= 0 || this.current_size <= 0) {
            this.is_alive = false;
        }
    }

    void draw(Camera camera) {
        if (!is_alive) return ;
        // デカルト系から画面系へ変換する
        PVector screen_pos = world_to_screen(this.world_pos, camera);

        if (screen_pos != null) {
            noStroke();

            // 色を線型補完して、変化させる
            float r = lerp(255, target_r, this.color_blend);
            float g = lerp(255, target_g, this.color_blend);
            float b = lerp(255, target_b, this.color_blend);

            fill(r, g, b, this.alpha);
            ellipse(screen_pos.x, screen_pos.y, this.current_size, this.current_size);
        }
    }
}
