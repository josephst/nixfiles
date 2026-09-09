"""Exercise the scan action without scanner hardware or a running journal."""

import json
import os
from pathlib import Path
import shutil
import stat
import subprocess
import tempfile
import unittest


class ScanActionTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="brscan-test-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.home = self.root / "home"
        self.home.mkdir()
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.inbox = self.root / "inbox with spaces"
        self.staging = self.root / "private staging"
        self.events = self.root / "events.jsonl"
        self.config = self.home / ".brscan-skey" / "scantofile.config"
        self.config.parent.mkdir()
        self.config.write_text("")
        mock = self.bin / "mock"
        mock.write_text(
            "#!" + shutil.which("python3") + "\n" + r'''
import json, os, pathlib, stat, subprocess, sys
tool = pathlib.Path(sys.argv[0]).name
args = sys.argv[1:]
with open(os.environ["TEST_EVENTS"], "a") as f:
    f.write(json.dumps([tool, args]) + "\n")
status = int(os.environ.get("TEST_" + tool.upper() + "_STATUS", "0"))
if tool == "scanner":
    output = pathlib.Path(args[args.index("--outputfile") + 1])
    assert stat.S_IMODE(output.parent.stat().st_mode) == 0o700
    assert not list(pathlib.Path(os.environ["BRSCAN_SKEY_SCAN_DIR"]).iterdir())
    if os.environ.get("TEST_EMPTY_SCAN") != "1":
        output.write_bytes(b"TIFF data")
elif tool == "tiffcp":
    pathlib.Path(args[-1]).write_bytes(pathlib.Path(args[-2]).read_bytes())
elif tool == "tiff2pdf":
    if os.environ.get("TEST_EMPTY_PDF") != "1":
        sys.stdout.buffer.write(b"%PDF-complete")
elif tool == "mv":
    assert args[:4] == ["--no-copy", "-T", "--update=none-fail", "--"]
    if not status:
        sys.exit(subprocess.run([os.environ["TEST_REAL_MV"], *args]).returncode)
sys.exit(status)
'''
        )
        mock.chmod(0o755)
        for name in ["scanner", "tiffcp", "tiff2pdf", "logger", "mv", "sleep"]:
            (self.bin / name).symlink_to(mock)
        self.script = Path(__file__).with_name("scantofile.sh")
        self.env = dict(os.environ)
        self.env.update(
            HOME=str(self.home),
            PATH=str(self.bin) + os.pathsep + os.environ["PATH"],
            BRSCAN_SKEY_SCAN_DIR=str(self.inbox),
            BRSCAN_SKEY_STAGING_DIR=str(self.staging),
            BRSCAN_SKEY_SCANIMAGE=str(self.bin / "scanner"),
            TEST_EVENTS=str(self.events),
            TEST_REAL_MV=shutil.which("mv"),
        )

    def run_scan(self, **env):
        return subprocess.run(
            [shutil.which("bash"), str(self.script), "brother net device with spaces"],
            env={**self.env, **env}, capture_output=True, text=True, umask=0o022,
        )

    def calls(self, tool):
        if not self.events.exists():
            return []
        return [args for name, args in map(json.loads, self.events.read_text().splitlines())
                if name == tool]

    def assert_failed(self, result, status, message, retain_pdf=False):
        self.assertEqual(result.returncode, status, result.stderr)
        self.assertNotIn("is created", result.stdout)
        self.assertEqual(list(self.inbox.iterdir()), [])
        self.assertTrue(any(message in " ".join(args) for args in self.calls("logger")))
        if not retain_pdf:
            self.assertEqual(list(self.staging.iterdir()), [])

    def test_success_publishes_only_pdf_and_cleans_private_files(self):
        result = self.run_scan()
        self.assertEqual(result.returncode, 0, result.stderr)
        outputs = list(self.inbox.iterdir())
        self.assertEqual(len(outputs), 1)
        self.assertEqual(outputs[0].suffix, ".pdf")
        self.assertEqual(outputs[0].read_bytes(), b"%PDF-complete")
        self.assertEqual(stat.S_IMODE(outputs[0].stat().st_mode), 0o644)
        self.assertEqual(list(self.staging.iterdir()), [])
        self.assertEqual(stat.S_IMODE(self.staging.stat().st_mode), 0o700)
        args = self.calls("scanner")[0]
        self.assertEqual(args[args.index("--device-name") + 1], "brother net device with spaces")
        self.assertEqual(args[args.index("--size") + 1], "Letter")

    def test_custom_geometry_and_duplex(self):
        self.config.write_text("size=215.9x279.4\nresolution=600\nduplex=ON\n")
        result = self.run_scan()
        self.assertEqual(result.returncode, 0, result.stderr)
        args = self.calls("scanner")[0]
        self.assertEqual(args[args.index("--size") + 1], "215.9x279.4")
        self.assertEqual(args[args.index("--resolution") + 1], "600")
        self.assertEqual(args.count("--source"), 1)
        self.assertEqual(args[args.index("--source") + 1], "ADF_C")

    def test_nonempty_failed_scan_is_not_converted(self):
        result = self.run_scan(TEST_SCANNER_STATUS="7")
        self.assert_failed(result, 7, "exit code 7")
        self.assertEqual(len(self.calls("scanner")), 2)
        self.assertEqual(self.calls("tiffcp"), [])
        self.assertEqual(self.calls("mv"), [])

    def test_empty_scan_is_failure_even_with_zero_exit(self):
        result = self.run_scan(TEST_EMPTY_SCAN="1")
        self.assert_failed(result, 1, "exit code 0")
        self.assertEqual(self.calls("tiffcp"), [])

    def test_compression_failure_is_logged_and_not_published(self):
        result = self.run_scan(TEST_TIFFCP_STATUS="8")
        self.assert_failed(result, 8, "compression failed with exit code 8")
        self.assertEqual(self.calls("tiff2pdf"), [])

    def test_pdf_failure_is_logged_and_not_published(self):
        result = self.run_scan(TEST_TIFF2PDF_STATUS="9")
        self.assert_failed(result, 9, "PDF conversion failed with exit code 9")
        self.assertEqual(self.calls("mv"), [])

    def test_empty_pdf_is_not_published(self):
        result = self.run_scan(TEST_EMPTY_PDF="1")
        self.assert_failed(result, 1, "output is empty")
        self.assertEqual(self.calls("mv"), [])

    def test_failed_move_keeps_completed_pdf_in_private_directory(self):
        result = self.run_scan(TEST_MV_STATUS="18")
        self.assert_failed(result, 18, "publication failed with exit code 18", retain_pdf=True)
        pdfs = list(self.staging.glob("job.*/scan.pdf"))
        self.assertEqual(len(pdfs), 1)
        self.assertEqual(pdfs[0].read_bytes(), b"%PDF-complete")
        self.assertIn(str(pdfs[0]), result.stderr)
        self.assertEqual(stat.S_IMODE(pdfs[0].parent.stat().st_mode), 0o700)
        self.assertEqual(list(pdfs[0].parent.iterdir()), pdfs)


if __name__ == "__main__":
    unittest.main()
