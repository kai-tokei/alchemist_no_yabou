// 四元数のメモ
// ある軸ベクトルを中心にtheta回転させる四元数
// q = cos(theta / 2) + (xi + yj + zk) sin(theta / 2)
// ある座標点pをこの四元数を使って、回転させるには
// p' = q p inv(q)

// x, y, z軸中心のdegを考える。これを四元数で回転させたい
// x, y, z軸中心の回転を、すべて四元数で表す
// y(yaw) -> x(pitch) -> z(roll) の順番で合成するのが標準なので
// q_total = q_z * q_x * q_y
// 掛け算には、四元数の掛け算の公式をつかう(調べる)

// 四元数の構造体
class Quaternion {
    float w, x, y, z;

    Quaternion(float w, float x, float y, float z) {
        this.w = w;
        this.x = x;
        this.y = y;
        this.z = z;
    }

    // 共役四元数を返す
    Quaternion conjugate() {
        float norm = norm_q(this);
        float norm_p = norm * norm;

        return new Quaternion(
            w / norm_p, -x / norm_p, -y / norm_p, -z / norm_p
        );
    }
}

// 四元数の掛け算
Quaternion multiply_q(Quaternion a, Quaternion b) {
    float w = a.w*b.w - a.x*b.x - a.y*b.y - a.z*b.z;
    float x = a.w*b.x + a.x*b.w + a.y*b.z - a.z*b.y;
    float y = a.w*b.y - a.x*b.z + a.y*b.w + a.z*b.x;
    float z = a.w*b.z + a.x*b.y - a.y*b.x + a.z*b.w;

    return new Quaternion(w, x, y, z);
}

// ベクトル軸の回転を四元数に変換する
Quaternion deg_to_q(float angle, float x, float y, float z) {
    float q_x = x * sin(radians(angle) / 2);
    float q_y = y * sin(radians(angle) / 2);
    float q_z = z * sin(radians(angle) / 2);
    float q_w = cos(radians(angle) / 2);

    float len = sqrt(q_w*q_w + q_x*q_x + q_y*q_y + q_z*q_z);

    // 正規化して誤差を減らす
    return new Quaternion(
        q_w / len, q_x / len, q_y / len, q_z / len
    );
}

// 四元数のノルムを求める
float norm_q(Quaternion q) {
    return sqrt(
        q.w*q.w + q.x*q.x + q.y*q.y + q.z*q.z
    );
}

// 3軸のオイラー角を四元数形式に変換する
Quaternion angle_to_q(float angle_x, float angle_y, float angle_z) {
    Quaternion q_x = deg_to_q(angle_x, 1, 0, 0);
    Quaternion q_y = deg_to_q(angle_y, 0, 1, 0);
    Quaternion q_z = deg_to_q(angle_z, 0, 0, 1);

    return multiply_q(q_z, multiply_q(q_x, q_y));
}

// 座標pを四元数qで回転させる
PVector rotate_vector(PVector p, Quaternion q) {
    // 点を四元数形式に変換する
    Quaternion p_q = new Quaternion(0, p.x, p.y, p.z);

    // p' = q * p * inv(q)
    Quaternion q_inv = q.conjugate();
    Quaternion pq = multiply_q(q, p_q);
    Quaternion p_prime = multiply_q(pq, q_inv);

    return new PVector(p_prime.x, p_prime.y, p_prime.z);
}
