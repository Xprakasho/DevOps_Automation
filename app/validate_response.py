
import json
import sys


def main():
    data = json.load(sys.stdin)

    expected = {
        "application": "project-everest",
        "version": "1.2.0",
        "status": "running",
    }

    for key, value in expected.items():
        if data.get(key) != value:
            print(
                f"Validation failed: expected {key}={value!r}, "
                f"got {data.get(key)!r}",
                file=sys.stderr,
            )
            return 1

    print("Application response validation passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
