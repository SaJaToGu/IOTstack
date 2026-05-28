# IOTstack Smoke Tests

This directory contains lightweight checks for the repository structure and shell scripts.

Run all checks from the repository root:

```bash
./tests/smoke_tests.sh
```

The tests do not start Docker containers or install services. They only verify that important files exist and that shell scripts parse successfully with `bash -n`.
