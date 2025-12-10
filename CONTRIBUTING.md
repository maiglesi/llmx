# Contributing to LLMX

Thank you for your interest in contributing to LLMX! This document provides guidelines and information for contributors.

## Ways to Contribute

### 1. Report Issues
- Bug reports
- Feature requests
- Documentation improvements
- Protocol enhancement proposals

### 2. Submit Pull Requests
- Bug fixes
- New features
- Documentation updates
- Example additions

### 3. Improve Documentation
- Fix typos
- Clarify explanations
- Add examples
- Translate to other languages

## Development Setup

```bash
# Clone the repo
git clone https://github.com/maiglesi/llmx.git
cd llmx

# Make scripts executable
chmod +x bin/*

# Add to PATH for testing
export PATH="$PATH:$(pwd)/bin"

# Test basic functionality
llmx --help
orchestrate --help
```

## Code Standards

### Shell Scripts

- Use `#!/usr/bin/env bash` shebang
- Follow [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- Use `shellcheck` for linting
- Include usage documentation in scripts

### LLMX Protocol

- Follow the specification in `spec/LLMX-v1.0.md`
- Maintain backwards compatibility
- Document any protocol extensions

## Pull Request Process

1. **Fork** the repository
2. **Create a branch** for your feature/fix
   ```bash
   git checkout -b feature/my-feature
   ```
3. **Make changes** and test thoroughly
4. **Commit** with clear messages
   ```bash
   git commit -m "feat: add support for custom message types"
   ```
5. **Push** to your fork
   ```bash
   git push origin feature/my-feature
   ```
6. **Open a Pull Request** with:
   - Clear description of changes
   - Any related issues
   - Test results

## Commit Message Format

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructuring
- `test`: Tests
- `chore`: Maintenance

Examples:
```
feat(cli): add broadcast command for multi-LLM messaging
fix(orchestrate): handle timeout in parallel reviews
docs(examples): add workflow patterns documentation
```

## Protocol Enhancement Proposals (PEP)

For significant protocol changes:

1. Open an issue with `[PEP]` prefix
2. Describe the proposed change
3. Explain motivation and use cases
4. Show example messages
5. Discuss backwards compatibility
6. Wait for community feedback

## Testing

### Manual Testing

```bash
# Test CLI
llmx --help
llmx send gemini 'REQ:{o:"test",pr:5}'

# Test orchestrator
orchestrate --help
```

### Lint Scripts

```bash
# Install shellcheck
brew install shellcheck  # macOS
apt install shellcheck   # Linux

# Run linter
shellcheck bin/*
```

## Code of Conduct

### Our Standards

- Be respectful and inclusive
- Welcome newcomers
- Accept constructive criticism
- Focus on what's best for the community

### Unacceptable Behavior

- Harassment or discrimination
- Trolling or insulting comments
- Personal or political attacks
- Publishing private information

## Questions?

- Open an issue for questions
- Join discussions on GitHub
- Check existing issues first

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to LLMX!
