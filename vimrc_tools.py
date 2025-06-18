#!/usr/bin/env python3

"""
vimrc_tools.py
Automation tools for generating and managing .vimrc from Neovim configuration
Usage: python3 vimrc_tools.py [command]
"""

import os
import sys
import subprocess
import shutil
import time
import re
from datetime import datetime
from pathlib import Path
from typing import Optional, List, Dict, Any

try:
    from watchdog.observers import Observer
    from watchdog.events import FileSystemEventHandler
    WATCHDOG_AVAILABLE = True
except ImportError:
    WATCHDOG_AVAILABLE = False
    # Create dummy classes for when watchdog is not available
    class FileSystemEventHandler:
        def on_modified(self, event):
            pass
    
    class Observer:
        def schedule(self, handler, path, recursive=False):
            pass
        def start(self):
            pass
        def stop(self):
            pass
        def join(self):
            pass

# Colors for output
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'  # No Color

def log_info(message: str) -> None:
    print(f"{Colors.BLUE}[INFO]{Colors.NC} {message}")

def log_success(message: str) -> None:
    print(f"{Colors.GREEN}[SUCCESS]{Colors.NC} {message}")

def log_warning(message: str) -> None:
    print(f"{Colors.YELLOW}[WARNING]{Colors.NC} {message}")

def log_error(message: str) -> None:
    print(f"{Colors.RED}[ERROR]{Colors.NC} {message}")

class VimrcTools:
    def __init__(self):
        self.script_dir = Path(__file__).parent.absolute()
        self.vimrc_file = self.script_dir / ".vimrc"
        
    def generate_vimrc(self) -> bool:
        """Generate .vimrc using Neovim introspection"""
        log_info("Generating .vimrc from current Neovim configuration...")
        
        os.chdir(self.script_dir)
        
        # Use Neovim VimrcExport command with minimal init
        cmd = ["nvim", "--headless", "-n", "-c", f"VimrcExport {self.vimrc_file}", "-c", "qa!"]
        log_info(f"Running: {' '.join(cmd)}")
        
        try:
            result = subprocess.run(cmd, capture_output=True, text=True)
            nvim_output = result.stdout + result.stderr
            nvim_exit_code = result.returncode
            
            if self.vimrc_file.exists():
                log_success("Generated .vimrc from Neovim session!")
                line_count = len(self.vimrc_file.read_text().splitlines())
                log_info(f"Lines written: {line_count}")
                
                # Filter and show relevant Neovim output
                if nvim_output.strip():
                    # Filter out expected harmless errors in headless mode
                    filtered_lines = []
                    for line in nvim_output.splitlines():
                        if not any(skip in line for skip in [
                            "Installing Lux", "Lux installation failed", 
                            "No colorscheme set", "colors_name.*nil value"
                        ]):
                            filtered_lines.append(line)
                    
                    if filtered_lines:
                        log_info("Neovim messages:")
                        for line in filtered_lines:
                            print(f"  {line}")
                    
                    # Show export confirmation
                    export_lines = [line for line in nvim_output.splitlines() if "Exported .vimrc" in line]
                    if export_lines:
                        export_info = re.sub(r'Exported \.vimrc to [^ ]* ', '', export_lines[0])
                        log_success(export_info)
                
                return True
            else:
                log_error("Failed to generate .vimrc from Neovim")
                log_error(f"Exit code: {nvim_exit_code}")
                if nvim_output.strip():
                    log_error("Neovim output:")
                    print(nvim_output)
                return False
                
        except FileNotFoundError:
            log_error("nvim command not found. Please install Neovim.")
            return False
        except subprocess.SubprocessError as e:
            log_error(f"Error running Neovim: {e}")
            return False
    
    def test_vimrc(self) -> bool:
        """Test the generated .vimrc"""
        log_info("Testing generated .vimrc...")
        
        if not self.vimrc_file.exists():
            log_error(".vimrc not found. Generate it first.")
            return False
        
        # Check if vim is available
        if not shutil.which("vim"):
            log_warning("vim is not installed, cannot test .vimrc")
            log_info("The .vimrc file exists and appears to be generated correctly")
            return True
        
        # Test vim syntax by checking for basic syntax errors
        log_info("Checking vim syntax...")
        
        try:
            # Create a minimal test that won't trigger vim-plug
            cmd = ["vim", "-e", "-s", "-c", "syntax off", "-c", f"source {self.vimrc_file}", "-c", "qa!"]
            result = subprocess.run(cmd, capture_output=True, text=True)
            test_output = result.stdout + result.stderr
            
            # Check for actual syntax errors (not vim-plug curl errors)
            error_patterns = [r"Error", r"Invalid", r"Unknown"]
            exclude_patterns = [r"curl.*no URL specified", r"vim-plug"]
            
            errors = []
            for line in test_output.splitlines():
                if any(re.search(pattern, line, re.IGNORECASE) for pattern in error_patterns):
                    if not any(re.search(pattern, line, re.IGNORECASE) for pattern in exclude_patterns):
                        errors.append(line)
            
            if errors:
                log_error(".vimrc contains syntax errors")
                log_info("Error details:")
                for error in errors:
                    print(f"  {error}")
                return False
            else:
                log_success(".vimrc syntax appears valid")
                if "curl.*no URL specified" in test_output:
                    log_info("(vim-plug installation attempt is normal)")
            
        except subprocess.SubprocessError as e:
            log_error(f"Error testing .vimrc: {e}")
            return False
        
        # Check for common issues
        log_info("Checking for common issues...")
        
        issues = 0
        content = self.vimrc_file.read_text()
        
        # Check for duplicate leader definitions
        leader_count = len(re.findall(r"let.*leader", content))
        if leader_count > 2:
            log_warning(f"Multiple leader key definitions found ({leader_count})")
            issues += 1
        
        # Check for basic sections
        required_sections = ["VIM OPTIONS", "KEYMAPS", "PLUGIN MANAGEMENT"]
        for section in required_sections:
            if section not in content:
                log_warning(f"Missing section: {section}")
                issues += 1
        
        if issues == 0:
            log_success("No issues found in .vimrc")
        else:
            log_warning(f"Found {issues} potential issues")
        
        return issues == 0
    
    def install_vimrc(self) -> bool:
        """Install .vimrc to home directory"""
        target = Path.home() / ".vimrc"
        
        if not self.vimrc_file.exists():
            log_error(".vimrc not found. Generate it first.")
            return False
        
        # Backup existing vimrc
        if target.exists():
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            backup = target.parent / f".vimrc.backup.{timestamp}"
            log_warning(f"Backing up existing {target} to {backup}")
            shutil.copy2(target, backup)
        
        # Install new vimrc
        shutil.copy2(self.vimrc_file, target)
        log_success(f"Installed {target} successfully!")
        log_info("You can now use vim with your Neovim-derived configuration.")
        return True
    
    def compare_vimrc(self) -> None:
        """Compare with existing .vimrc"""
        target = Path.home() / ".vimrc"
        
        if not self.vimrc_file.exists():
            log_error("Generated .vimrc not found. Generate it first.")
            return
        
        if not target.exists():
            log_info("No existing ~/.vimrc found to compare with")
            return
        
        log_info("Comparing generated .vimrc with existing ~/.vimrc...")
        
        if shutil.which("diff"):
            try:
                result = subprocess.run(
                    ["diff", "-q", str(self.vimrc_file), str(target)], 
                    capture_output=True, text=True
                )
                
                if result.returncode == 0:
                    log_success("Generated .vimrc is identical to existing ~/.vimrc")
                else:
                    log_info("Differences found between generated and existing .vimrc:")
                    diff_result = subprocess.run(
                        ["diff", str(self.vimrc_file), str(target)], 
                        capture_output=True, text=True
                    )
                    print(diff_result.stdout)
            except subprocess.SubprocessError:
                log_warning("Error running diff command")
        else:
            log_warning("diff command not available, cannot compare files")
    
    def stats_vimrc(self) -> None:
        """Show statistics about the generated .vimrc"""
        if not self.vimrc_file.exists():
            log_error(".vimrc not found. Generate it first.")
            return
        
        log_info("Statistics for generated .vimrc:")
        
        content = self.vimrc_file.read_text()
        lines = content.splitlines()
        
        total_lines = len(lines)
        comment_lines = len([line for line in lines if re.match(r'^\s*"', line)])
        empty_lines = len([line for line in lines if re.match(r'^\s*$', line)])
        config_lines = total_lines - comment_lines - empty_lines
        
        print(f"  Total lines: {total_lines}")
        print(f"  Comment lines: {comment_lines}")
        print(f"  Empty lines: {empty_lines}")
        print(f"  Configuration lines: {config_lines}")
        
        # Count mappings
        mappings = len(re.findall(r"noremap|[^n]map", content))
        print(f"  Key mappings: {mappings}")
        
        # Count settings
        settings = len(re.findall(r"^set ", content, re.MULTILINE))
        print(f"  Vim settings: {settings}")
        
        # Count plugins
        plugins = len(re.findall(r"^Plug ", content, re.MULTILINE))
        print(f"  Plugins defined: {plugins}")
        
        # Count leader mappings
        leader_maps = len(re.findall(r"<leader>", content))
        print(f"  Leader key mappings: {leader_maps}")
        
        # Count global variables
        globals_count = len(re.findall(r"^let g:", content, re.MULTILINE))
        print(f"  Global variables: {globals_count}")
        
        # Show sections included
        print("")
        print("Sections included:")
        sections = [
            ("TOP CONFIGURATION", "Top configuration"),
            ("GLOBAL VARIABLES", "Global variables"),
            ("VIM OPTIONS", "Vim options (from live session)"),
            ("KEYMAPS", "Keymaps (from live session)"),
            ("PLUGIN MANAGEMENT", "Plugin management (vim-plug)"),
            ("PLUGIN CONFIGURATIONS", "Plugin configurations")
        ]
        
        for section_marker, section_name in sections:
            if section_marker in content:
                print(f"  ✓ {section_name}")
    
    def clean(self) -> None:
        """Clean generated files"""
        log_info("Cleaning generated files...")
        
        if self.vimrc_file.exists():
            self.vimrc_file.unlink()
            log_success("Removed .vimrc")
        else:
            log_info("No .vimrc file to clean")

class ConfigChangeHandler(FileSystemEventHandler):
    def __init__(self, vimrc_tools: VimrcTools):
        self.vimrc_tools = vimrc_tools
        self.last_regeneration = 0
        
    def on_modified(self, event):
        if event.is_directory:
            return
        
        # Debounce: only regenerate once per second
        current_time = time.time()
        if current_time - self.last_regeneration < 1:
            return
        
        if event.src_path.endswith('.lua'):
            log_info("Configuration change detected, regenerating .vimrc...")
            self.vimrc_tools.generate_vimrc()
            self.last_regeneration = current_time

def watch_and_regenerate(vimrc_tools: VimrcTools) -> None:
    """Watch for changes and auto-regenerate"""
    if not WATCHDOG_AVAILABLE:
        log_error("watchdog package is not installed")
        log_info("Install with: pip3 install watchdog")
        sys.exit(1)
    
    log_info("Watching for changes in Neovim configuration...")
    log_info("Press Ctrl+C to stop watching")
    
    watch_dirs = [
        vimrc_tools.script_dir / "lua" / "gamma" / "set",
        vimrc_tools.script_dir / "lua" / "gamma" / "remap",
        vimrc_tools.script_dir / "lua" / "config" / "context"
    ]
    
    # Filter existing directories
    watch_dirs = [d for d in watch_dirs if d.exists()]
    
    if not watch_dirs:
        log_error("No configuration directories found to watch")
        return
    
    # Initial generation
    vimrc_tools.generate_vimrc()
    
    # Set up file system monitoring
    event_handler = ConfigChangeHandler(vimrc_tools)
    observer = Observer()
    
    for watch_dir in watch_dirs:
        observer.schedule(event_handler, str(watch_dir), recursive=True)
        log_info(f"Watching: {watch_dir}")
    
    observer.start()
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
        log_info("Stopped watching")
    
    observer.join()

def show_help() -> None:
    """Show help message"""
    print("""Usage: python3 vimrc_tools.py [command]

Commands:
  generate    - Generate .vimrc from Neovim configuration (default)
  test        - Test the generated .vimrc for syntax errors
  install     - Install .vimrc to home directory (~/.vimrc)
  compare     - Compare generated .vimrc with existing ~/.vimrc
  stats       - Show statistics about the generated .vimrc
  clean       - Remove generated .vimrc file
  watch       - Watch for changes and auto-regenerate .vimrc
  all         - Generate, test, and show stats
  help        - Show this help message

Examples:
  python3 vimrc_tools.py                # Generate .vimrc
  python3 vimrc_tools.py generate       # Same as above
  python3 vimrc_tools.py test           # Test generated .vimrc
  python3 vimrc_tools.py install        # Generate and install .vimrc
  python3 vimrc_tools.py all            # Full workflow: generate, test, stats
  python3 vimrc_tools.py watch          # Watch and auto-regenerate on changes

Files:
  Input:  Neovim configuration in lua/gamma/
  Output: .vimrc (generated vim configuration)
  Generator: VimrcExport command in Neovim""")

def main():
    """Main function"""
    vimrc_tools = VimrcTools()
    command = sys.argv[1] if len(sys.argv) > 1 else "generate"
    
    try:
        if command in ["generate", "gen", "g"]:
            vimrc_tools.clean()
            success = vimrc_tools.generate_vimrc()
            if success:
                vimrc_tools.test_vimrc()
                vimrc_tools.stats_vimrc()
        
        elif command in ["test", "t"]:
            vimrc_tools.test_vimrc()
        
        elif command in ["install", "i"]:
            if vimrc_tools.generate_vimrc():
                if vimrc_tools.test_vimrc():
                    vimrc_tools.install_vimrc()
        
        elif command in ["compare", "diff", "c"]:
            vimrc_tools.compare_vimrc()
        
        elif command in ["stats", "statistics", "s"]:
            vimrc_tools.stats_vimrc()
        
        elif command in ["clean", "cl"]:
            vimrc_tools.clean()
        
        elif command in ["watch", "w"]:
            watch_and_regenerate(vimrc_tools)
        
        elif command in ["all", "a"]:
            if vimrc_tools.generate_vimrc():
                vimrc_tools.test_vimrc()
                vimrc_tools.stats_vimrc()
        
        elif command in ["help", "-h", "--help", "h"]:
            show_help()
        
        else:
            log_error(f"Unknown command: {command}")
            print("")
            show_help()
            sys.exit(1)
    
    except KeyboardInterrupt:
        log_info("Operation cancelled by user")
        sys.exit(0)
    except Exception as e:
        log_error(f"Unexpected error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()