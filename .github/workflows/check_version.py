import yaml
import subprocess
import re


def check_changelog(version):
    with open("CHANGELOG.md", "r") as file:
        # Split the changelog into sections for each version
        changelog_sections = re.split(r"(?<=## \[)(.*?)(?=\])", file.read())

        # The most recent version should be the first section after the split
        # (The 0th section is everything before the first heading)
        most_recent_version = changelog_sections[1]
        print(most_recent_version)

        if version != most_recent_version:
            print(f"Version {version} not found in most recent changes in CHANGELOG.md")
            exit(1)


def get_version(file_path):
    with open(file_path, "r") as file:
        pubspec_content = yaml.safe_load(file)
        return pubspec_content["version"]


def checkout_main_branch():
    subprocess.run(["git", "fetch", "origin", "main"])
    subprocess.run(["git", "checkout", "FETCH_HEAD", "--", "pubspec.yaml"])


def compare_versions(old_version, new_version):
    old_version_parts = old_version.split("+")[0].split(".")
    new_version_parts = new_version.split("+")[0].split(".")

    for i in range(len(old_version_parts)):
        if int(new_version_parts[i]) < int(old_version_parts[i]):
            return -1
        if int(new_version_parts[i]) > int(old_version_parts[i]):
            return 1
    return 0


# Read the version in the PR
pr_version = get_version("pubspec.yaml")

# Read the version in the main branch
checkout_main_branch()
main_version = get_version("pubspec.yaml")

# Compare versions
result = compare_versions(main_version, pr_version)
if result == 0:
    print(f"Version not updated. main: {main_version}, PR: {pr_version}")
    exit(1)
if result == -1:
    print(f"Version downgraded. main: {main_version}, PR: {pr_version}")
    exit(1)

check_changelog(pr_version)

print(f"Version updated. main: {main_version}, PR: {pr_version}")
