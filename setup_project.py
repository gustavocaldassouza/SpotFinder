#!/usr/bin/env python3
"""
Script to add Swift files to Xcode project
This script helps automate adding the new files to the Xcode project file.
"""

import os
import uuid


def generate_uuid():
    """Generate a unique 24-character hex string for Xcode."""
    return uuid.uuid4().hex[:24].upper()


def find_swift_files(base_path):
    """Find all Swift files in the project directory."""
    swift_files = []
    exclude_dirs = {".git", ".build", "DerivedData", ".xcassets"}

    for root, dirs, files in os.walk(base_path):
        # Remove excluded directories from the search
        dirs[:] = [d for d in dirs if d not in exclude_dirs]

        for file in files:
            if file.endswith(".swift"):
                rel_path = os.path.relpath(os.path.join(root, file), base_path)
                swift_files.append(rel_path)

    return sorted(swift_files)


def main():
    project_path = "/Users/gustavocaldasdesouza/Workspace/SpotFinder"
    source_path = os.path.join(project_path, "SpotFinder")

    print("📱 SpotFinder - Xcode Project Setup Helper\n")
    print("=" * 60)

    # Find all Swift files
    swift_files = find_swift_files(source_path)

    print(f"\n✅ Found {len(swift_files)} Swift files:\n")

    # Group files by directory
    files_by_dir = {}
    for file_path in swift_files:
        dir_name = os.path.dirname(file_path) or "Root"
        if dir_name not in files_by_dir:
            files_by_dir[dir_name] = []
        files_by_dir[dir_name].append(os.path.basename(file_path))

    # Print organized structure
    for dir_name, files in sorted(files_by_dir.items()):
        print(f"📁 {dir_name}")
        for file in sorted(files):
            print(f"   └─ {file}")
        print()

    print("=" * 60)
    print("\n⚠️  MANUAL STEPS REQUIRED:\n")
    print("Since modifying .pbxproj files programmatically is complex,")
    print("please follow these steps in Xcode:\n")

    print("1️⃣  Open Xcode:")
    print("   cd /Users/gustavocaldasdesouza/Workspace/SpotFinder")
    print("   open SpotFinder.xcodeproj\n")

    print("2️⃣  Add files to project:")
    print("   • Right-click on 'SpotFinder' folder in Project Navigator")
    print("   • Select 'Add Files to SpotFinder...'")
    print("   • Select these folders:")
    for dir_name in sorted(set(os.path.dirname(f) for f in swift_files)):
        if dir_name and dir_name != ".":
            print(f"     ✓ {dir_name}")
    print("   • Check 'Copy items if needed'")
    print("   • Check 'SpotFinder' target")
    print("   • Click 'Add'\n")

    print("3️⃣  Delete old files:")
    print("   • Find 'ContentView.swift' in navigator")
    print("   • Right-click → Delete → Move to Trash\n")

    print("4️⃣  Verify Info.plist:")
    print("   • Check that Info.plist exists in SpotFinder folder")
    print("   • Should contain location permission descriptions\n")

    print("5️⃣  Build and run:")
    print("   • Select a simulator (iOS 17+)")
    print("   • Press Cmd + R\n")

    print("=" * 60)
    print("\n📚 For detailed instructions, see:")
    print("   • SETUP_GUIDE.md")
    print("   • README.md\n")

    print("✨ Project structure is ready!")
    print("   Just follow the manual steps above to complete setup.\n")


if __name__ == "__main__":
    main()
