#!/bin/sh
set -e # exit on error

if ! git diff --cached --quiet; then
  echo "Aborted: staged changes detected in git"
  exit 1
fi

echo "+ curl -s https://static.rust-lang.org/dist/channel-rust-stable.toml"
latest=$(curl -s https://static.rust-lang.org/dist/channel-rust-stable.toml | grep -A1 '^\[pkg.rust\]' | grep -oP 'version = "\K[0-9.]+')
echo "Updating to rust $latest"

sed -i "s/^rust .*/rust $latest/" .tool-versions

if git diff --quiet .tool-versions; then
  echo "Already on latest rust, nothing to do"
  exit 0
fi

echo "Running regression tests..."
echo "+ docker run --rm --user $(id -u):$(id -g) -e CARGO_HOME=/tmp/cargo -v $PWD:/src -w /src rust:$latest cargo test"
docker run --rm --user "$(id -u):$(id -g)" -e CARGO_HOME=/tmp/cargo -v "$PWD":/src -w /src "rust:$latest" cargo test

echo "Committing upgrades..."
git commit --include .tool-versions \
--message "chore: Upgrade build to rust $latest" \
--message 'Upgraded by `upgrade-rust.sh`' \
--message 'bump: patch'
