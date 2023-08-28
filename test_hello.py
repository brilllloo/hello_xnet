import unittest
from hello import FileWriter

class TestWriteToFile(unittest.TestCase):
    
    def test_writing_to_file(self):
        file_path = "hello.txt"
        msg = "Hello, X-NET!"

        myfilewriter = FileWriter(file_path)

        myfilewriter.write(msg)

        with open(file_path, "r") as f:
            content = f.read()
            expected_content = msg
            self.assertEqual(content, expected_content)

if __name__ == "__main__":
    unittest.main(argv=['first-arg-is-ignored'], exit=False)
