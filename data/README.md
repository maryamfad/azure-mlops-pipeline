# Data

Datasets are **not** committed to Git. `scripts/download_data.py` saves them to `data/raw/`
(ignored by Git), and `infra/setup.ps1` uploads them to Azure Storage, which is the source of
truth for training.

## Default of Credit Card Clients

- **Source:** UCI Machine Learning Repository, dataset 350
  (https://archive.ics.uci.edu/dataset/350/default+of+credit+card+clients)
- **License:** CC BY 4.0
- **Size:** about 30,000 rows, 23 features
- **Target:** `default`, 1 if the client defaulted on the next month's payment
- **Features:** credit limit, demographics, 6 months of repayment status, bill amounts
  and payment amounts (columns `X1`–`X23`; see the UCI page for descriptions)

Citation: Yeh, I. (2009). Default of Credit Card Clients [Dataset].
UCI Machine Learning Repository.
