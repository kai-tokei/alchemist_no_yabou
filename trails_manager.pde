class TrailManager {
    ArrayList<Trail> all_trails;

    TrailManager() {
        this.all_trails = new ArrayList<Trail>();
    }

    // 残像の追加
    void add_trail(PVector world_pos, int size, int meteor_type) {
        Trail t = new Trail(world_pos, size, meteor_type);
        this.all_trails.add(t);
    }

    void update() {
        // 既存の残像を更新し、寿命が尽きたものは削除する
        for (int i = this.all_trails.size() - 1; i >= 0; i--) {
            Trail t = this.all_trails.get(i);
            t.update();
            if (!t.is_alive) {
                this.all_trails.remove(i);
            }
        }
    }

    void draw(Camera camera) {
        for (Trail t : this.all_trails) {
            t.draw(camera);
        }
    }
}
