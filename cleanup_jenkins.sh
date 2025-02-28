#!/bin/bash

## This script is for cleaning up jenkins repository
## version: v0.1
## date: 2025-02-27

# Find the lastest full backup snapshot
latest_snapshot=$(restic -r "$RESTIC_REPO_JENKINS" snapshots --json | jq -r '
  map(select(any(.tags[]; startswith("jenkins-fullBackup"))))
  | sort_by(.time)
  | last')


# Check if a latest snapshot was found
if [[ -z "$latest_snapshot" || "$latest_snapshot" == "null" ]]; then
  echo "No full backup snapshots was found"
  echo "Normal exit. Not an error"
  exit 0
fi

# Extract the snapshot ID and creation time
latest_snapshot_id=$(echo "$latest_snapshot" | jq -r '.short_id')
latest_snapshot_time=$(echo "$latest_snapshot" | jq -r '.time')

echo "Latest Snapshot ID: $latest_snapshot_id"
echo "Latest Snapshot Time: $(echo "$latest_snapshot_time" | cut -d'T' -f1)"

# Find old snapshots created before the latest snapshot
# Exclude initial backup snapshot
old_snapshots=$(restic -r "$RESTIC_REPO_JENKINS" snapshots --json | jq -r --arg latest "$latest_snapshot_time" '
  map(select(.time < $latest and all(.tags[]; startswith("jenkins-initialFullBackup") | not)))
  | .[].short_id')

# Check if there are old snapshots to delete
if [[ -z "$old_snapshots" ]]; then
  echo "No old snapshots to delete."
  echo "Normal exit. Not an error"
  exit 0
fi

echo "Old Snapshots to Delete:"
echo "$old_snapshots"

# Delete old snapshots
for snapshot in $old_snapshots; do
  echo "Deleting snapshot: $snapshot"
  if ! restic -r "$RESTIC_REPO_JENKINS" forget "$snapshot"; then
    echo "!!Warning: Failed to delete snapshot $snapshot, skipping..."
  fi
done

# Optimize the Restic respository
echo "Running Restic prune..."
if ! restic -r "$RESTIC_REPO_JENKINS" prune; then
  echo "!!Warning: Failed to run prune, please check your repository."
fi

echo "Jenkins snapshots cleanup completed successfully!"
