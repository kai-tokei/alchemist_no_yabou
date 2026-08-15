class CatchEffectManager {
    ArrayList<CatchEffect> catch_effects;

    CatchEffectManager() {
        catch_effects = new ArrayList<CatchEffect>();
    }

    void add_catch_effect(PVector world_pos, int meteor_type) {
        this.catch_effects.add(new CatchEffect(world_pos, meteor_type));
    }

    void update(Camera camera) {
        for (int i = this.catch_effects.size() - 1; i >= 0; i--) {
            CatchEffect c = this.catch_effects.get(i);

            c.update(camera);

            if (!c.is_alive) {
                this.catch_effects.remove(i);
            }
        }
    }

    void draw() {
        for (CatchEffect c : this.catch_effects) {
            c.draw();
        }
    }
}
