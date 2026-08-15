class Moon {
    PVector pos;
    PImage img;
    float scale;

    Moon(PVector pos, float scale) {
        this.pos = pos;
        this.img = img;
        this.scale = scale;

        this.img = loadImage("images/moon.png");

        this.img.resize(
            int(this.img.width * scale),
            int(this.img.height * scale)
        );
    }

    void draw(Camera camera) {
        PVector moon_screen_pos = world_to_screen(pos, camera);
        if (moon_screen_pos != null) {
            noStroke();
            fill(255, 255, 255, 15);
            ellipse(
                moon_screen_pos.x,
                moon_screen_pos.y,
                250,
                250
            );
            ellipse(
                moon_screen_pos.x,
                moon_screen_pos.y,
                150,
                150
            );

            tint(200, 255);
            image(
                this.img,
                moon_screen_pos.x - this.img.width / 2,
                moon_screen_pos.y - this.img.height / 2
            );
        }
    }
}
