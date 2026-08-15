class Hand {
    PImage img_hand_paper;
    PImage img_hand_rock;
    boolean is_grisping; // 手を握っているか
    boolean on_grisping; // 手を握った直後か

    // 当たり判定の大きさ
    int judgement_width = 100;
    int judgement_height = 100;

    // 掴んでいる時間を維持するためのタイマー
    int grasp_timer = 0;
    int grasp_duration = 50;


    Hand() {
        this.img_hand_paper = loadImage("images/hand_paper.png");
        this.img_hand_rock = loadImage("images/hand_rock.png");

        this.is_grisping = false;
    }

    void start_grisp() {
        if (!is_grisping) {
            grasp_timer = 0;
            is_grisping = true;
            on_grisping = true;
        }
    }

    // 対象の座標を握っているかどうか
    boolean grisp(PVector screen_pos) {
        int anchor_x = width - this.img_hand_paper.width + judgement_width / 2;
        int anchor_y = height - this.img_hand_paper.height + judgement_height * 2 / 3;

        // 範囲内に入っていて、かつ手を握っていたら、「握っている」という判定を返す
        return
            (anchor_x < screen_pos.x && screen_pos.x < anchor_x + this.judgement_width) &&
            (anchor_y < screen_pos.y && screen_pos.y < anchor_y + this.judgement_height) &&
            this.on_grisping;
    }

    void update() {
        if (is_grisping && grasp_timer > grasp_duration) {
            grasp_timer = 0;
            is_grisping = false;
        }
        else {
            on_grisping = false;
            grasp_timer++;
        }
    }

    void draw() {
        tint(128, 180);

        if (this.is_grisping) {
            image(this.img_hand_rock,
                width - this.img_hand_rock.width,
                height - this.img_hand_rock.height
            );
        }
        else {
            image(this.img_hand_paper,
                width - this.img_hand_paper.width,
                height - this.img_hand_paper.height
            );
        }

        /*
        fill(50, 168, 82);
        rectMode(CORNER);
        rect(
            width - this.img_hand_paper.width + judgement_width / 2,
            height - this.img_hand_paper.height + judgement_height * 2 / 3,
            judgement_width,
            judgement_height
        );
        */
    }
}
