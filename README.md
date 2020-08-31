
# gclone  

A modified version of the [rclone](//github.com/rclone/rclone) to implement dynamic replacement of service account files for google drive backend.

## Installation

```bash
curl -L https://raw.githubusercontent.com/wiserain/gclone/master/install.sh | sudo bash
```

## Usage

### Dynamic replacement of service account files

Set `service_account_file_path` in your rclone.conf. Everytime when `rateLimitExceeded` or `userRateLimitExceeded` error occurs, gclone tries to replace with another service account file in the path in random order.

```text
[gc]
type = drive
scope = drive
service_account_file_path = /path/to/service/account/files
```

### Support folder/file id

gclone supports folder/file id in src/dst path.

```bash
gclone copy gc:{folde_id1} gc:{folde_id2}  --drive-server-side-across-configs
```

folde_id can be a common directory, shared directory, shared drive.

```bash
gclone copy gc:{folde_id1} gc:{folde_id2}/media/  --drive-server-side-across-configs
```

```bash
gclone copy gc:{share_file_id} gc:{folde_id2}  --drive-server-side-across-configs
```
