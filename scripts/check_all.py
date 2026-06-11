import subprocess
import sys

scripts = [
    "check_tgw.py",
    "check_vpc.py",
    "check_ec2.py"
]

for script in scripts:

    print("\n")
    print("=" * 80)
    print(f"Running {script}")
    print("=" * 80)

    subprocess.run(
        [sys.executable, script],
        check=False
    )