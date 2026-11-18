#!/bin/sh
set -e # exit on error

if ! git diff --cached --quiet; then
  echo "Aborted: staged changes detected in git"
  exit 1
fi

rust=$(grep '^rust ' .tool-versions | awk '{print $2}')

echo "+ docker run --rm --user $(id -u):$(id -g) -e CARGO_HOME=/tmp/cargo -v $PWD:/src -w /src rust:$rust sh -c 'cargo update && cargo install cargo-edit && cargo upgrade --incompatible'"
docker run --rm --user "$(id -u):$(id -g)" -e CARGO_HOME=/tmp/cargo -v "$PWD":/src -w /src "rust:$rust" sh -c 'cargo update && cargo install cargo-edit && cargo upgrade --incompatible'

if git diff --quiet Cargo.toml Cargo.lock; then
  echo "No crate updates available, nothing to do"
  exit 0
fi

echo "Running regression tests..."
echo "+ docker run --rm --user $(id -u):$(id -g) -e CARGO_HOME=/tmp/cargo -v $PWD:/src -w /src rust:$rust cargo test"
docker run --rm --user "$(id -u):$(id -g)" -e CARGO_HOME=/tmp/cargo -v "$PWD":/src -w /src "rust:$rust" cargo test

echo "Committing upgrades..."
git commit --include Cargo.toml --include Cargo.lock \
--message "chore: Dependency upgrades (cargo)" \
--message 'Upgraded by `upgrade-crates.sh`' \
--message 'bump: patch'
