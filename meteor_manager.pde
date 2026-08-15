class MeteorManager {
    ArrayList<Meteor> meteors; // 隕石
    TrailManager trail_manager; // 全ての隕石の軌跡

    int meteor_size = 12; // 隕石の大きさ

    MeteorManager() {
        meteors = new ArrayList<Meteor>();
        trail_manager = new TrailManager();
    }

    void add_meteor(PVector world_pos, PVector rot_vec, int meteor_type) {
        this.meteors.add(new Meteor(
            world_pos,
            rot_vec,
            random(0.1f, 0.7f),
            meteor_size,
            meteor_type
        ));
    }

    void update(Hand hand, GrispingCallback grisping_callback) {
        trail_manager.update();

        // 隕石をそれぞれ更新する
        for (int i = this.meteors.size() - 1; i >= 0; i--) {
            Meteor m = this.meteors.get(i);
            m.update(this.trail_manager);

            // もし隕石が手で握られていたら
            // その隕石を削除してコールバックを実行し、削除
            if (m.screen_pos != null) {
                if (hand.grisp(m.screen_pos)) {
                    grisping_callback.onGrisping(m.world_pos, m.meteor_type);
                    m.is_alive = false;
                }
            }

            // もし隕石が消滅していたら、削除
            if (!m.is_alive) {
                this.meteors.remove(i);
            }
        }
    }

    void draw(Camera camera) {
        // 軌跡を描画
        trail_manager.draw(camera);

        // 隕石を描画
        for (Meteor m : this.meteors) {
            m.draw(camera);
        }
    }
}

