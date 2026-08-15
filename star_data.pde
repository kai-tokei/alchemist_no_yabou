/*
本構造体は、Yale大学の星図録をデータ化するために作成した
http://tdc-www.harvard.edu/catalogs/bsc5.html
https://heasarc.gsfc.nasa.gov/cgi-bin/W3Browse/w3query.pl?&tablehead=name%3Dheasarc_hipparcos%26description%3DHipparcos+Main+Catalog%26url%3Dhttp%3A%2F%2Fheasarc.gsfc.nasa.gov%2FW3Browse%2Fstar-catalog%2Fhipparcos.html%26archive%3D%26radius%3D1%26mission%3DSTAR%2BCATALOG%26priority%3D3&mission=STAR+CATALOG&Action=More+Options&Action=Parameter+Search&ConeAdd=1

ヒッパルコス星表
https://ja.wikipedia.org/wiki/%E3%83%92%E3%83%83%E3%83%91%E3%83%AB%E3%82%B3%E3%82%B9%E6%98%9F%E8%A1%A8
*/


class StarData {
    // --------- CSV から読み込んだデータ
    String name; // 星の識別番号
    char spect_type; // スペクトル型 （O, B, A, F, G, K, M）
    float vmag; // 明るさ（数値が小さいほど明るくなる）

    // --------- ゲーム用
    PVector world_pos; // 天球上の3次元位置
    PVector screen_pos; // 画面座標系での座標（毎回更新）
    boolean is_visible; // 描画するかどうか（明滅や、カメラ後ろなど）
    float twinkle_phase;

    StarData(
        String name,
        String spect_type,
        float vmag,
        float ra_deg,
        float dec_deg
    ) {
        this.name = name;
        this.vmag = vmag;

        // スペクトル型は、最初の一文字のみ
        this.spect_type =
            (spect_type != null && spect_type.length() > 0 ? spect_type.charAt(0) : 'N');

        // 角度をラジアンに変換
        float ra_rad = radians(ra_deg);
        float dec_rad = radians(dec_deg);

        // 半径1の球体座標系からXYZへ変換する
        float x = cos(dec_rad) * cos(ra_rad);
        float y = cos(dec_rad) * sin(ra_rad);
        float z = sin(dec_rad);

        this.world_pos = new PVector(x, y, z);

        // ゲーム用変数の初期化
        this.screen_pos = new PVector(0, 0);
        this.is_visible = false;
        this.twinkle_phase = random(100, 3000);
    }
}


// 星空を生成する
ArrayList<StarData> generate_stars(int number, float milky_factor) {
    ArrayList<StarData> stars = new ArrayList<StarData>();

    // --- 天の川を再現する ---
    for (int i = 0; i < 3000; i++) {
        String name = "MilkyWayStar_" + i;
        String spect_type = "Sol";
        float vmag = random(0.0f, 6.5f); // 明るさのばらつき

        float ra_deg = 0;
        float dec_deg = 0;

        // 全体のN割の星を「天の川の帯」に集中させる
        if (random(1.0f) < milky_factor) {
            // 1. まずは天の川のベースとなる直線を引く（赤経を全周にばら撒く）
            ra_deg = random(0.0f, 180.0f);

            // ななめの天の川のベースを作る（例：赤経に合わせてサイン波でうねらせる）
            // これで天球をななめに1周する帯の「中心線」ができる
            float milky_way_center = sin(radians(ra_deg)) * 45.0f; // 45度傾いた天の川

            // 中心線のまわりに、ガウス分布（中央が濃くなるランダム）で星を散らす
            // randomGauge()の代わりに、randomを複数回足して引くと中央が濃くなる
            float thickness = (random(-15, 15) + random(-15, 15)) / 2.0f;
            dec_deg = milky_way_center + thickness;

        } else {
            // 残りの3割は、天の川以外の場所にまばらにばら撒く（背景の星）
            ra_deg = random(0.0f, 180.0f);
            dec_deg = degrees(asin(random(-1.0f, 1.0f)));
        }

        // 星のインスタンス生成
        StarData star = new StarData(name, spect_type, vmag, ra_deg, dec_deg);

        // カメラから離す（半径1000の球面にすっ飛ばす）
        star.world_pos.mult(1000.0f);

        stars.add(star);
    }

    return stars;
}


// 全ての星の画面座標を一括計算する
void calculate_stars(ArrayList<StarData> stars, Camera camera) {
    for (StarData star : stars) {
        // カメラ関数を用いて、座標変換する
        PVector s_pos = world_to_screen(star.world_pos, camera);

        // カメラの視野に入っていたら、描画トリガーをONにする
        if (s_pos != null) {
            star.screen_pos = s_pos;
            star.is_visible = true;
        }
        else {
            star.is_visible = false;
        }
    }
}

// 星を描画する
void draw_stars(ArrayList<StarData> stars, float size, int max_brightness, float brightness_scale) {
    strokeWeight(size);
    for (StarData star : stars) {
        if (star.is_visible) {
            // 星の等級から、最大255の明るさへ調整
            float star_brightness =
                max_brightness * pow(2.511886, -star.vmag) *
                ((frameCount % star.twinkle_phase) < int(star.twinkle_phase / 2) ? 1.0f : 0);

            stroke(star_brightness);
            point(star.screen_pos.x, star.screen_pos.y);
        }
    }
}
