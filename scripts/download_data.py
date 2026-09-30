"""Download the UCI 'Default of Credit Card Clients' dataset to data/raw/.

Usage (from the repo root):
    python scripts/download_data.py
"""
from pathlib import Path

from ucimlrepo import fetch_ucirepo

DATASET_ID = 350  # UCI: Default of Credit Card Clients
OUT_PATH = Path(__file__).resolve().parents[1] / "data" / "raw" / "credit_default.csv"


def main() -> None:
    print(f"Downloading UCI dataset {DATASET_ID}...")
    dataset = fetch_ucirepo(id=DATASET_ID)

    df = dataset.data.features.copy()
    target = dataset.data.targets
    df["default"] = target.iloc[:, 0].values

    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(OUT_PATH, index=False)

    print(f"Saved {len(df):,} rows x {df.shape[1]} columns to {OUT_PATH}")
    print(f"Default rate: {df['default'].mean():.1%}")


if __name__ == "__main__":
    main()
