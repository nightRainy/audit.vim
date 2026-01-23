#!/usr/bin/env python3
"""audit.vim - Lightweight code audit system with Neovim

A tool for managing code audit sessions with ctags, bookmarks, and LSP integration.
Supports project-based sessions with quick file navigation and symbol lookup.
"""
import os
import time
import json
import shutil
import argparse
import subprocess as sb
import fnmatch
import ast
from datetime import datetime
from pathlib import Path
from typing import Optional, List, Dict, Set
from rich.console import Console
from rich.table import Table

WORKSPACE = os.path.expanduser("~/.audit.vim")
CONN = Console()


def log(msg: str, *args, **kwargs) -> None:
    """Print log message with [+] prefix."""
    print('[+]', msg, *args, **kwargs)


def sizeof_fmt(num: float, suffix: str = "B") -> str:
    """Convert bytes to human-readable format."""
    for unit in ["", "K", "M", "G", "T", "P", "E", "Z"]:
        if abs(num) < 1024.0:
            return f"{num:3.1f}{unit}{suffix}"
        num /= 1024.0
    return f"{num:.1f}Yi{suffix}"


def _num_lines(filename: str) -> int:
    """Count number of lines in a file."""
    if not os.path.exists(filename):
        return 0
    with open(filename, 'r', encoding='utf-8', errors='ignore') as f:
        return sum(1 for _ in f)


def _filesz(filename: str) -> str:
    """Get human-readable file size."""
    if not os.path.exists(filename):
        return '-'
    return sizeof_fmt(os.stat(filename).st_size)


class Project:
    """Represents an audit project with tags and bookmarks."""

    OUT_LIST = "files"
    OUT_TAGS = "tags"
    OUT_BOOKMARK = "bookmark"

    def __init__(self, src: str, data: Optional[str] = None):
        """Initialize project with source directory and optional data directory."""
        self.src = os.path.abspath(src)
        self.data = data

    def create(self, suffixes: List[str], excludes: Optional[List[str]] = None, tag: bool = True) -> None:
        """Create project session with file collection and tags."""
        if self.data is None:
            self.data = os.path.join(WORKSPACE, str(int(time.time())))
        if not os.path.exists(self.data):
            os.mkdir(self.data)
        self.collect_files(suffixes, excludes)
        if tag:
            self.create_tags()

    def remove(self) -> None:
        """Remove project data directory."""
        if os.path.exists(self.data):
            shutil.rmtree(self.data)

    @property
    def timestamp(self) -> int:
        """Get project creation timestamp."""
        return int(os.path.basename(self.data))

    @property
    def f_bookmark(self) -> str:
        """Get bookmark file path."""
        return os.path.join(self.data, self.OUT_BOOKMARK)

    @property
    def f_list(self) -> str:
        """Get file list path."""
        return os.path.join(self.data, self.OUT_LIST)

    @property
    def f_tags(self) -> str:
        """Get tags file path."""
        return os.path.join(self.data, self.OUT_TAGS)

    def collect_files(self, suffixes: List[str], excludes: Optional[List[str]] = None) -> None:
        """Collect all files matching the given suffixes."""
        exclude_paths = [Path(e).absolute() for e in excludes] if excludes else []
        log("collecting files ...")

        files = []
        num_ignored = 0
        num_excluded = 0

        for p in Path(self.src).glob("**/*"):
            if p.is_symlink() or not p.is_file():
                continue

            # Check exclusions
            if exclude_paths and any(ex in p.absolute().parents for ex in exclude_paths):
                num_excluded += 1
                continue

            # Check suffix
            if p.suffix.lower() in suffixes:
                files.append(str(p))
            else:
                num_ignored += 1

        log(f"collected {len(files)} files, {num_ignored} ignored, {num_excluded} excluded")

        with open(self.f_list, 'w', encoding='utf-8') as f:
            f.write('\n'.join(files) + '\n')

    def create_tags(self) -> None:
        """Generate ctags file."""
        log("adding ctags ...")
        if os.path.exists(self.f_tags):
            os.remove(self.f_tags)
        cmd = ['ctags', '--fields=+l', '--links=no', '-L', self.f_list, '-f', self.f_tags]
        sb.call(cmd)


class AVIM:
    """Main application class for managing audit sessions."""

    def __init__(self):
        """Initialize AVIM with workspace and configuration."""
        self.basedir = os.path.dirname(os.path.realpath(__file__))
        self.suffix_file = os.path.join(self.basedir, "suffixes.txt")
        self.index = os.path.join(WORKSPACE, "index.json")
        if not os.path.exists(WORKSPACE):
            os.mkdir(WORKSPACE)

    @property
    def sessions(self) -> Dict[str, str]:
        """Get all audit sessions from index file."""
        if not os.path.exists(self.index):
            return {}
        with open(self.index, "r", encoding='utf-8') as f:
            return json.load(f)

    @property
    def suffixes(self) -> List[str]:
        """Get list of file suffixes to track."""
        suffixes: Set[str] = set()
        with open(self.suffix_file, 'r', encoding='utf-8') as f:
            for line in f:
                ft = line.strip()
                if ft:
                    suffixes.add(ft.lower())
        return list(suffixes)

    def save_sessions(self, sessions: Dict[str, str]) -> None:
        """Save sessions to index file."""
        with open(self.index, "w", encoding='utf-8') as f:
            json.dump(sessions, f, indent=2)

    def find_project(self, startpoint: str, sessions: Dict[str, str]) -> Optional[Project]:
        """Find project by recursively searching parent directories."""
        if not startpoint:
            return None
        p = os.path.abspath(startpoint)
        if p in sessions:
            return Project(p, sessions[p])
        parent = os.path.dirname(p)
        if parent == p:
            return None
        return self.find_project(parent, sessions)

    def _read_bookmark(self, filename: str) -> str:
        """Read bookmark count from file, return '-' if unavailable."""
        if not os.path.exists(filename):
            return '-'
        try:
            with open(filename, 'r', encoding='utf-8') as f:
                f.readline()  # Skip first line
                line = f.readline()
                if not line:
                    return '-'
            bm_sessions = line.split("=", 1)[1]
            bm_sessions = ast.literal_eval(bm_sessions)
            count = sum(len(bms) for bms in bm_sessions['default'].values())
            return count
        except (IndexError, KeyError, SyntaxError, ValueError):
            return '-'

    def do_make(self, args: argparse.Namespace) -> None:
        """Create new audit session for a project."""
        proj = Project(args.src)
        if not os.path.exists(proj.src):
            log("path not exists:", proj.src)
            return

        sessions = self.sessions
        if proj.src in sessions:
            log("project existed:", proj.src)
            if not args.force:
                return
            # Clear old session first
            self.do_rm(proj.src, sessions[proj.src])

        # Create session with tags
        proj.create(self.suffixes, args.excludes, args.tag)
        sessions = self.sessions
        sessions[proj.src] = proj.data
        self.save_sessions(sessions)

    def do_rm(self, src: str, sessions: Optional[Dict[str, str]] = None, is_glob: bool = False) -> None:
        """Remove audit session(s) by source path or glob pattern."""
        if sessions is None:
            sessions = self.sessions

        # Find matching sessions
        if is_glob:
            matches = list(fnmatch.filter(sessions.keys(), src))
        else:
            key = os.path.abspath(src)
            matches = [key] if key in sessions else []

        if not matches:
            log(f"not match any sessions: {src}")
            return

        # Remove matched sessions
        for key in matches:
            proj = Project(key, sessions[key])
            proj.remove()
            log("remove session:", proj.src)
            del sessions[proj.src]

        self.save_sessions(sessions)

    def do_info(self, args: argparse.Namespace) -> None:
        """Display information about all audit sessions."""
        sessions = self.sessions
        if not sessions:
            log("No data")
            return

        fields = ['location', 'timestamp', 'files', 'ctags', 'bookmark']
        t = Table(*fields)
        rows = []

        for src, data in sessions.items():
            proj = Project(src, data)

            # Apply filter if specified
            if args.filter:
                lhs, rhs = args.filter, proj.src
                if args.ignore_case:
                    lhs, rhs = lhs.lower(), rhs.lower()
                if lhs not in rhs:
                    continue

            # Mark non-existent paths in red
            display_src = f"[bold red]{src}[/]" if not os.path.exists(src) else src
            timestamp = datetime.fromtimestamp(proj.timestamp)

            rows.append([
                display_src,
                timestamp,
                _num_lines(proj.f_list),
                _filesz(proj.f_tags),
                self._read_bookmark(proj.f_bookmark),
            ])

        # Sort and display
        idx = fields.index(args.sortby)
        for row in sorted(rows, key=lambda r: r[idx], reverse=True):
            t.add_row(*[str(col) for col in row])
        CONN.print(t)

    def do_open(self, args: argparse.Namespace) -> None:
        """Open nvim with project environment configured."""
        sessions = self.sessions
        env = os.environ.copy()
        cmd = ['nvim', '-R', '-M']

        # Handle tag or file argument
        if args.tag:
            cmd.extend(['-t', args.tag])
        if args.file:
            cmd.append(args.file)
            fd = os.path.abspath(args.file)
            startpoint = fd if os.path.isdir(fd) else os.path.dirname(fd)
        else:
            startpoint = os.getcwd()

        # Find and configure project
        proj = self.find_project(startpoint, sessions)
        if not proj:
            log("project not found:", startpoint)
            env['AVIM_SRC'] = os.getcwd()
        else:
            env['AVIM_SRC'] = proj.src
            env['AVIM_BOOKMARK'] = proj.f_bookmark
            if os.path.exists(proj.f_tags):
                env['AVIM_TAGS'] = proj.f_tags

        if args.extra_args:
            cmd.extend(args.extra_args)
        sb.call(cmd, env=env)


def main() -> None:
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description='Lightweight code audit system with Neovim',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s make -t .              Create audit session for current directory
  %(prog)s make -t -f ./project   Force recreate session
  %(prog)s info                   List all sessions
  %(prog)s info -i android        Filter sessions (case-insensitive)
  %(prog)s open                   Open nvim in audit mode
  %(prog)s open MainActivity.java Open specific file
  %(prog)s rm .                   Remove current session
  %(prog)s rm -g "*android*"      Remove sessions by pattern
        """
    )
    subparsers = parser.add_subparsers(dest='action', help='Available commands')

    # make command
    p_add = subparsers.add_parser(
        'make',
        help='Create new audit session from current directory'
    )
    p_add.add_argument('src', nargs='?', default='.',
                      help='Project root directory (default: current directory)')
    p_add.add_argument('-t', dest='tag', action='store_true',
                      help='Create ctags index')
    p_add.add_argument('-f', dest='force', action='store_true',
                      help='Force overwrite existing session')
    p_add.add_argument('-e', dest='excludes', nargs='+',
                      help='Exclude directories from indexing')

    # rm command
    p_rm = subparsers.add_parser('rm', help='Remove audit session')
    p_rm.add_argument('-g', '--glob', action='store_true',
                     help='Enable glob pattern matching')
    p_rm.add_argument('src', nargs='*', default=['.'],
                     help='Session path(s) to remove')

    # info command
    p_info = subparsers.add_parser(
        'info',
        help='List information about audit sessions',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    p_info.add_argument("-i", dest="ignore_case", action="store_true",
                       help="Case-insensitive filter")
    p_info.add_argument("filter", nargs="?",
                       help="Filter projects by location")
    p_info.add_argument("-s", dest="sortby",
                       choices=["location", "files", "timestamp"],
                       default="timestamp",
                       help="Sort results by column")

    # open command
    p_open = subparsers.add_parser('open', help='Open nvim in audit mode')
    p_open.add_argument('file', nargs="?",
                       help='File to open')
    p_open.add_argument('-t', dest='tag',
                       help='Open file by tag name')
    p_open.add_argument("extra_args", nargs="*",
                       help="Extra arguments passed to nvim")

    args = parser.parse_args()

    # Execute command
    avim = AVIM()
    if args.action == 'make':
        avim.do_make(args)
    elif args.action == 'rm':
        for src in args.src:
            avim.do_rm(src, is_glob=args.glob)
    elif args.action == 'info':
        avim.do_info(args)
    elif args.action == 'open':
        avim.do_open(args)
    else:
        parser.print_help()


if __name__ == '__main__':
    main()
