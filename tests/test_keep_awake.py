"""Run the keep-awake command with a private configuration and fake systemd."""
import json
import os
from pathlib import Path
import signal
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "src/usr/share/argvus/power/sh/keep-awake.sh"


class KeepAwake(unittest.TestCase):
    def setUp(self):
        Path("/tmp/argvus").mkdir(exist_ok=True)
        directory = tempfile.TemporaryDirectory(dir="/tmp/argvus")
        self.addCleanup(directory.cleanup)
        self.root = Path(directory.name)
        bin_dir = self.root / "bin"
        bin_dir.mkdir()
        self.env = dict(os.environ, ARGVUS_CONFIG_HOME=str(self.root),
                        PATH=f"{bin_dir}:{os.environ['PATH']}")
        self.data = self.root / "argvus/data"
        self.marker = self.data / "power/.keep-awake"
        self.legacy = self.data / ".keep-awake"
        self.pending = self.data / "internal/keep-awake.pending"
        self.write("unit", "active")
        idle_binary = self.root / "hypridle"
        idle_binary.symlink_to("/usr/bin/sleep")
        idle = subprocess.Popen([idle_binary, "60"])
        self.addCleanup(idle.wait, 3)
        self.addCleanup(idle.terminate)
        self.write("pid", str(idle.pid))
        for name, code in {
            "argvus": """
case "$2" in
  get) cat "$ARGVUS_CONFIG_HOME/value" 2>/dev/null || echo null ;;
  set) [ ! -e "$ARGVUS_CONFIG_HOME/persist-fail" ] || exit 1
       echo "$4" > "$ARGVUS_CONFIG_HOME/value" ;;
esac
""",
            "systemctl": """
root=$ARGVUS_CONFIG_HOME
[ ! -e "$root/bus-fail" ] || exit 1
case "$2" in
  show) printf 'LoadState=%s\nActiveState=%s\nMainPID=%s\n' "$(cat "$root/load" 2>/dev/null || echo loaded)" "$(cat "$root/unit")" "$(cat "$root/pid")" ;;
  stop|start)
    [ ! -e "$root/apply-fail" ] || exit 1
    if [ -e "$root/pause" ]; then touch "$root/entered"; sleep 20; fi
    if [ "$2" = stop ]; then echo inactive > "$root/unit"; else echo active > "$root/unit"; fi
    if [ -e "$root/external" ]; then echo false > "$root/value"; fi ;;
esac
""",
            "notify-send": "exit 0\n",
        }.items():
            executable = bin_dir / name
            executable.write_text("#!/bin/sh\n" + code)
            executable.chmod(0o755)

    def write(self, name, value=""):
        (self.root / name).write_text(value + "\n")

    def call(self, operation, code=0):
        result = subprocess.run([SCRIPT, operation], env=self.env, text=True,
                                capture_output=True, timeout=10)
        self.assertEqual(result.returncode, code, result.stderr)
        return result.stdout.strip()

    def test_legacy_precedence_and_success(self):
        self.assertEqual(self.call("status"), "disabled")
        self.data.mkdir(parents=True)
        self.legacy.write_text("enabled\n")
        self.assertEqual(self.call("status"), "enabled")
        self.write("value", "false")
        self.assertEqual(self.call("status"), "disabled")
        self.assertEqual(self.call("on"), "enabled")
        self.assertEqual(self.marker.read_text(), "enabled\n")
        self.assertEqual(json.loads(self.call("status-json"))["state"], "applied")
        self.assertEqual(self.call("off"), "disabled")
        self.assertEqual(self.legacy.read_text(), "disabled\n")
        self.assertEqual((self.root / "unit").read_text(), "active\n")

    def test_partial_failures_and_retry(self):
        self.write("persist-fail")
        self.call("on", 1)
        self.assertEqual(self.call("status"), "disabled")
        (self.root / "persist-fail").unlink()
        self.marker.mkdir(parents=True)
        self.call("on", 1)
        self.assertEqual(self.call("status"), "enabled")
        self.assertEqual((self.root / "unit").read_text(), "active\n")
        self.marker.rmdir()
        self.write("apply-fail")
        self.call("on", 1)
        self.assertEqual(json.loads(self.call("status-json"))["state"], "pending")
        (self.root / "apply-fail").unlink()
        self.call("on")
        self.assertFalse(self.pending.exists())
        self.write("apply-fail")
        self.call("off", 1)
        self.assertTrue(self.pending.exists())
        self.assertEqual(json.loads(self.call("status-json"))["state"], "pending")

    def test_unit_and_bus_unavailable(self):
        self.write("load", "not-found")
        self.call("on", 1)
        self.assertEqual(json.loads(self.call("status-json"))["state"], "unavailable")
        self.write("bus-fail")
        self.call("off", 1)
        self.assertFalse((self.root / "value").exists())

    def test_external_preference_change_during_application_is_preserved(self):
        self.write("external")
        self.call("on", 1)
        self.assertEqual((self.root / "value").read_text(), "false\n")
        self.assertTrue(self.pending.exists())
        self.assertEqual(json.loads(self.call("status-json"))["state"], "pending")

    def test_external_change_is_reported(self):
        self.call("on")
        self.write("unit", "active")
        self.assertEqual(json.loads(self.call("status-json")), {
            "requested": "enabled", "hypridle": "active", "state": "pending",
        })
        self.write("value", "false")
        self.assertEqual(self.call("status"), "disabled")
        self.assertEqual(self.marker.read_text(), "enabled\n")

    @unittest.skipUnless(os.environ.get("ARGVUS_TEST_ARGVUS"), "requires an argvus binary")
    def test_real_config_preference(self):
        binary = Path(os.environ["ARGVUS_TEST_ARGVUS"]).resolve()
        wrapper = self.root / "bin/argvus"
        wrapper.unlink()
        wrapper.symlink_to(binary)
        self.assertEqual(self.call("status"), "disabled")
        self.assertEqual(self.call("on"), "enabled")
        self.assertEqual(json.loads(self.call("status-json"))["state"], "applied")
        self.assertEqual(self.call("off"), "disabled")

    def test_startup_skips_hypridle_for_saved_request(self):
        session = SCRIPT.parents[7] / "argvus-session/src/usr/bin/argvus-sessionctl"
        executable = self.root / "bin/hypridle"
        executable.write_text("#!/bin/sh\nexit 99\n")
        executable.chmod(0o755)
        self.write("value", "true")
        self.marker.parent.mkdir(parents=True)
        self.marker.write_text("disabled\n")
        result = subprocess.run([session, "run", "hypridle"], env=self.env,
                                capture_output=True, timeout=4)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_concurrent_toggles(self):
        with subprocess.Popen([SCRIPT, "toggle"], env=self.env, stdout=subprocess.PIPE,
                              text=True) as first:
            second = self.call("toggle")
            self.assertEqual({first.communicate(timeout=10)[0].strip(), second},
                             {"enabled", "disabled"})
            self.assertEqual(first.returncode, 0)
        self.assertEqual(self.call("status"), "disabled")

    def test_interrupted_application_is_recoverable(self):
        import time

        self.write("pause")
        with subprocess.Popen([SCRIPT, "on"], env=self.env, start_new_session=True,
                              stdout=subprocess.DEVNULL) as child:
            try:
                deadline = time.monotonic() + 5
                while not (self.root / "entered").exists() and time.monotonic() < deadline:
                    time.sleep(0.02)
                self.assertTrue((self.root / "entered").exists())
            finally:
                if child.poll() is None:
                    os.killpg(child.pid, signal.SIGTERM)
                child.wait(timeout=5)
        (self.root / "pause").unlink()
        self.assertEqual(json.loads(self.call("status-json"))["state"], "pending")
        self.call("on")
        self.assertEqual(json.loads(self.call("status-json"))["state"], "applied")


if __name__ == "__main__":
    unittest.main()
