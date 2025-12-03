<div align="center">

# lol-lint

A strict, unapologetic linter for **LOLCODE**

[![Build Status](https://img.shields.io/github/actions/workflow/status/jerankda/lol-lint/ci.yml?branch=main)](https://github.com/jerankda/lol-lint/actions)
[![Crates.io](https://img.shields.io/crates/v/lol-lint.svg)](https://crates.io/crates/lol-lint)
[![Downloads](https://img.shields.io/crates/d/lol-lint.svg)](https://crates.io/crates/lol-lint)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Rust](https://img.shields.io/badge/rust-1.70+-orange.svg)](https://www.rust-lang.org)

**The language is a joke. This linter isn't.**

Built with [Rust](https://www.rust-lang.org) for speed and reliability.

</div>

---

## Features

| Feature | Description |
|---------|-------------|
| **Strict Syntax** | Validates LOLCODE syntax with zero tolerance for incomplete expressions |
| **Semantic Analysis** | Tracks variables, detects use-before-declaration, double declarations |
| **Code Quality** | Warns about unused variables, constant expressions, empty blocks |
| **JSON Output** | Machine-readable output for CI/CD integration |
| **Statistics** | Detailed metrics: LOC, variables, loops, conditionals, expressions |
| **Debug Mode** | Token and AST inspection for debugging |

## Installation

### From crates.io

```bash
cargo install lol-lint
```

### From source

```bash
cargo build --release
```

Binary location: `target/release/lol-lint`

## Usage

```bash
# basic linting
lol-lint file.lol

# with statistics
lol-lint file.lol --stats

# json output for ci/cd
lol-lint file.lol --json

# combined flags
lol-lint file.lol --json --stats --no-color

# debug mode (tokens + ast)
lol-lint file.lol --debug
```

### Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Clean (warnings tolerated) |
| `1` | Linting errors found |
| `2` | File error or parse failure |

## Checks

### Errors (exit code 1)

| Check | Description |
|-------|-------------|
| Undeclared variables | Using a variable before `I HAS A` |
| Double declarations | Declaring the same variable twice |
| Invalid assignments | Assigning to undeclared variables |
| Incomplete expressions | Missing `AN` in `SUM OF 3` |
| Malformed control flow | Invalid `O RLY?` or `IM IN YR LOOP` structures |

### Warnings (exit code 0)

| Check | Description |
|-------|-------------|
| Unused variables | Declared with `I HAS A` but never used |
| Constant expressions | `BOTH SAEM 5 AN 5` always evaluates to true |
| Empty blocks | Loop bodies or `YA RLY` branches with no statements |
| Missing branches | `O RLY?` without `NO WAI` |

## Examples

### Clean file

```bash
$ lol-lint example.lol --stats
✓ No linting issues found

--- Statistics ---
Lines of code:   17
Variables:       3
Loops:           1
Conditionals:    1
Expressions:     7
```

### File with errors and warnings

```bash
$ lol-lint bad.lol
error: use of undeclared variable 'x' (line 4, column 9)
error: variable 'y' declared twice (line 6, column 1)
warning: variable 'unused' declared but never used
warning: BOTH SAEM 5 AN 5 is always true (line 8, column 1)

2 errors, 2 warnings
```

### JSON output

```json
{
  "file": "file.lol",
  "errors": [],
  "warnings": [],
  "stats": {
    "lines_of_code": 17,
    "variables": 3,
    "loops": 1,
    "conditionals": 1,
    "expressions": 7
  }
}
```

## CI/CD Integration

### GitHub Actions

```yaml
- name: Lint LOLCODE
  run: |
    lol-lint src/main.lol --json > lint-results.json
    if [ $? -eq 1 ]; then
      echo "Linting failed"
      cat lint-results.json
      exit 1
    fi
```

### GitLab CI

```yaml
lint:
  script:
    - cargo build --release
    - ./target/release/lol-lint src/**/*.lol --json
  artifacts:
    reports:
      junit: lint-results.json
```

## Architecture

```
┌──────────┐     ┌────────┐     ┌─────────┐     ┌─────────┐
│  Lexer   │────▶│ Parser │────▶│   AST   │────▶│ Linter  │
└──────────┘     └────────┘     └─────────┘     └─────────┘
   Tokens         Syntax        Structure       Semantics
```

| Component | Responsibility |
|-----------|----------------|
| **Lexer** | Tokenizes LOLCODE source, handles BTW/OBTW comments |
| **Parser** | Validates syntax, builds abstract syntax tree |
| **AST** | Represents program structure (statements, expressions, blocks) |
| **Linter** | Performs semantic analysis and code quality checks |

## Development

### Running Tests

```bash
# run all example tests
./test_all.sh

# test specific file
cargo run -- examples/valid_complete.lol

# debug mode
cargo run -- examples/error_multiple.lol --debug
```

### Project Structure

```
lol-lint/
├── src/
│   ├── main.rs      # CLI and output formatting
│   ├── lexer.rs     # Tokenization
│   ├── parser.rs    # Syntax validation and AST building
│   ├── ast.rs       # AST node definitions
│   ├── linter.rs    # Semantic analysis
│   └── types.rs     # Token definitions
├── examples/        # Test files
└── test_all.sh      # Test runner
```

## License

MIT License - see [LICENSE](LICENSE) for details.

## Contributing

Issues and pull requests welcome. Please ensure:

- All tests pass (`./test_all.sh`)
- Code follows Rust conventions
- Comments are concise
- No unnecessary complexity
