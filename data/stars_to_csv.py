with open("stars1500.txt", "r", encoding="utf-8") as f:
    lines = f.readlines()

with open("stars.csv", "w", encoding="utf-8") as f:
    for line in lines:
        parts = [p.strip() for p in line.strip().strip("|").split("|")]
        f.write(",".join(parts) + "\n")
