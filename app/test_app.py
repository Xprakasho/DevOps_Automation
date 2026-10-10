import unittest

from app import response_for


class TestEverestApplication(unittest.TestCase):
    def test_home_endpoint(self):
        status, payload = response_for("/")

        self.assertEqual(status, 200)
        self.assertEqual(payload["application"], "project-everest")

    def test_health_endpoint(self):
        status, payload = response_for("/healthz")

        self.assertEqual(status, 200)
        self.assertEqual(payload["status"], "healthy")

    def test_unknown_endpoint(self):
        status, payload = response_for("/unknown")

        self.assertEqual(status, 404)
        self.assertEqual(payload["error"], "not found")


if __name__ == "__main__":
    unittest.main()
