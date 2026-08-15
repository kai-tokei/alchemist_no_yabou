class ScoreBoard {
    int x = width / 2;
    int y = height * 4 / 6;
    int score;

    float duration = 80;
    int duration_count;

    ScoreBoard () {
        this.score = 0;
    }

    void add (int s) {
        this.score += s;
        this.duration_count = 0;
    }

    void update() {
        if (this.duration_count < this.duration) this.duration_count ++;
    }

    void draw() {
        textAlign(CENTER);
        textSize(280);
        fill(255, 80);

        if (this.duration_count < this.duration) {
            text(this.score, x, y);
        }
    }
}
