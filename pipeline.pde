// カメラの構造体
class Camera {
    PVector pos; // カメラの座標
    float viewing_angle; // 視野角
    float focal_length; // 焦点距離
    Quaternion orientation; // カメラの向き

    Camera(
        PVector pos,
        float viewing_angle
    ) {
        this.pos = pos;

        this.viewing_angle = viewing_angle;
        this.focal_length = angle_to_focal_length(viewing_angle);

        this.orientation = new Quaternion(1, 0, 0, 0);
    }
}

// デカルト座標系を画面座標系に変換する写像
PVector world_to_screen(PVector pos, Camera camera) {
    // カメラの逆回転を求めて、星の座標をカメラ基準（ローカル空間）に変換
    Quaternion conjugate_q = camera.orientation.conjugate();

    PVector relative_pos = PVector.sub(pos, camera.pos);  // 相対座標を計算
    PVector local_pos = rotate_vector(relative_pos, conjugate_q);

    // カメラの後ろは描画しない（Zが小さいと描画しないと言うことは、Zは画面奥に向かってプラス。よって左手系）
    if (local_pos.z <= 0) {
        return null;
    }

    return new PVector(
        (local_pos.x / local_pos.z) * camera.focal_length + width / 2f,
        - (local_pos.y / local_pos.z) * camera.focal_length + height / 2f
    );
}

// 視野角と画面サイズから焦点距離を導出する関数
float angle_to_focal_length(float viewing_angle) {
    return width / (2 * tan(radians(viewing_angle) / 2));
}

// 経度・緯度（DEG）から、単位ベクトルを生成する
// ra: 経度, y軸中心, yaw
// dec: 緯度, x軸中心, pitch
PVector get_world_vector(float ra_deg, float dec_deg) {
    // 回転対象の単位ベクトル
    PVector vec = new PVector(0, 0, 1.0f);

    // 目標角度の四元数
    Quaternion q = angle_to_q(dec_deg, ra_deg, 0.0f);

    return rotate_vector(vec, q);
}
