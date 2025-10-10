#!/usr/bin/env python3

import os
import sys
import platform
import argparse
import subprocess
from pathlib import Path
from tempfile import mkdtemp

def print_header(text: str):
    print("\n" + "=" * 60)
    print(text)
    print("=" * 60)
    
def cpu_count():
    return os.cpu_count() or 4


def get_platform_info():
    system = platform.system().lower()
    machine = platform.machine().lower()
    
    if machine in ['x86_64', 'amd64']:
        arch = 'x86_64'
    elif machine in ['aarch64', 'arm64']:
        arch = 'aarch64'
    else:
        arch = machine
    
    return system, arch


def get_configure_target():
    system, arch = get_platform_info()
    
    if system == 'linux':
        if arch == 'x86_64':
            return 'linux-x86_64'
        elif arch == 'aarch64':
            return 'linux-aarch64'
    elif system == 'darwin':
        if arch == 'x86_64':
            return 'darwin64-x86_64-cc'
        elif arch == 'aarch64':
            return 'darwin64-arm64-cc'
    
    print(f"Unsupported platform: {system}-{arch}")
    sys.exit(1)


def run_command(cmd, cwd=None):
    print(f"Running: {cmd}")
    result = subprocess.run(cmd, shell=True, cwd=cwd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error: {result.stderr}")
        sys.exit(1)
    return result.stdout

def clone_repo(working_dir: Path, repo, branch, output_name):
    source_dir = working_dir / output_name
    
    print(f"Cloning {output_name}...")
    run_command(
        f"git clone --depth 1 --branch {branch} https://github.com/{repo}.git {output_name}",
        cwd=working_dir
    )
    run_command(f"git submodule update --init --recursive", cwd=source_dir)
    
    return source_dir


def clone_openssl(working_dir: Path, branch: str, output_name: str):
    return clone_repo(working_dir, "openssl/openssl", branch, output_name)


def clone_zlib(working_dir: Path, branch: str, output_name: str):
    return clone_repo(working_dir, "madler/zlib", branch, output_name)


def build_zlib(working_dir: Path, source_dir: Path, output_name: str):
    print_header(f"Building: {output_name}")
    
    prefix = working_dir / "zlib"
    
    configure_cmd = f"./configure --prefix={prefix.absolute()} --static"
    run_command(configure_cmd, cwd=source_dir)
    
    run_command(f"make -j{cpu_count()}", cwd=source_dir)
    run_command("make install", cwd=source_dir)
    
    print(f"✓ Build complete: {prefix}\n")
    return prefix


def build_openssl(working_dir: Path, source_dir: Path, output_name: str):
    print_header(f"Building: {output_name}")
    
    system, _ = get_platform_info()
    config_target = get_configure_target()
    prefix = working_dir / "openssl"
    
    configure_cmd = f"""./Configure {config_target} no-tests --prefix="{prefix.absolute()}" no-apps"""
    
    run_command(configure_cmd, cwd=source_dir)
    run_command(f"make -j{cpu_count()}", cwd=source_dir)
    run_command("make install", cwd=source_dir)
    
    print(f"✓ Build complete: {prefix}\n")


def create_archives(openssl_prefix: Path, artifact_dir: Path, openssl_version: str):
    system, arch = get_platform_info()
    archive_path = artifact_dir / f"{openssl_version}_{system}_{arch}.tar.zst"
    print(f"Creating {archive_path.name}...")
    
    artifact_dir.mkdir(exist_ok=True)
        
    run_command(
        f"tar -cf - * | zstd --ultra -22 -o {archive_path.absolute()}",
        cwd=openssl_prefix
    )

    size = archive_path.stat().st_size / (1024 * 1024)
    print(f"✓ Created {archive_path.name} ({size:.2f} MB)")


def main():
    print_header("OpenSSL + Zlib Build")
    
    parser = argparse.ArgumentParser()
    parser.add_argument("--openssl-version", type=str, required=True, default="3.3.2")
    parser.add_argument("--artifact-dir", type=str, required=True)
    parser.add_argument("--working-dir", type=str, required=True, default=mkdtemp())
    args = parser.parse_args()
    
    working_dir = Path(args.working_dir)
    working_dir.mkdir(exist_ok=True)
    
    print("\n[1/2] Building OpenSSL...")
    openssl_tag = f"openssl-{args.openssl_version}" if not args.openssl_version.startswith('openssl-') else args.openssl_version
    source = clone_openssl(working_dir, openssl_tag, f"openssl-{args.openssl_version}")
    openssl_prefix = build_openssl(working_dir, source, f"openssl-{args.openssl_version}")
    
    print("\n[2/2] Creating archives...")
    artifact_dir = Path(args.artifact_dir)
    create_archives(openssl_prefix, artifact_dir, openssl_tag)
    
    print_header("Build complete!")


if __name__ == "__main__":
    main()
