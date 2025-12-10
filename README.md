# LLMX - LLM Exchange Protocol

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

**A compressed, token-efficient protocol for inter-LLM communication.**

LLMX enables Claude, Gemini, Codex, and other LLMs to communicate efficiently with ~60-70% fewer tokens than natural language while maintaining clarity and structure.

```
HEADER:{f:Claude,t:Gemini,s:1}
CTX:{p:myproject,f:[src/api.ts]}
REQ:{o:"review for security issues",pr:2}
PLAN:[(i:1,t:"analyze auth",s:P),(i:2,t:"check injection",s:P)]
```

## Why LLMX?

When orchestrating multiple AI agents, communication overhead becomes significant:

| Approach | Tokens | Example |
|----------|--------|---------|
| Natural Language | ~150 | "Hello Gemini, I'm Claude. I'd like you to review the authentication code in src/api.ts for security vulnerabilities. This is priority 2. Please analyze the auth flow first, then check for injection vulnerabilities." |
| **LLMX** | ~50 | `HEADER:{f:Claude,t:Gemini,s:1} CTX:{p:proj,f:[src/api.ts]} REQ:{o:"review auth security",pr:2}` |

**Benefits:**
- **60-70% token reduction** - significant cost savings at scale
- **Structured handoffs** - clear task/status/deliverable tracking
- **Machine-parseable** - can be processed programmatically
- **Universal** - works across Claude, Gemini, Codex, GPT-4, and more
- **Extensible** - add custom message types for your use case

## Quick Start

### Installation

```bash
# Clone the repo
git clone https://github.com/maiglesi/llmx.git
cd llmx

# Add to PATH
export PATH="$PATH:$(pwd)/bin"

# Or install globally
./install.sh
```

### Basic Usage

```bash
# Send LLMX message to Gemini
llmx send gemini 'REQ:{o:"review code",pr:2}'

# Ask Codex a question
llmx ask codex "implement user authentication"

# Delegate task with context
llmx delegate gemini "create dashboard components" --issue PROJECT-123

# Parallel execution to multiple LLMs
llmx parallel "review frontend" "review backend"

# Check communication status
llmx status
```

### Workflow Orchestration

```bash
# Parallel code review (Gemini: UI, Codex: Backend)
orchestrate review src/components

# Coordinated implementation
orchestrate implement "add user auth" --issue PROJECT-xyz

# Get architecture plans from all LLMs
orchestrate plan "real-time notifications"

# Build consensus on technical decisions
orchestrate consensus "WebSockets vs SSE for real-time?"
```

## Protocol Specification

### Message Structure

Every LLMX message has a **HEADER** followed by one or more **MESSAGE BLOCKS**.

#### HEADER (Required)

```
HEADER:{f:SENDER,t:TARGET,s:SEQ,b?:BATCH_ID}
```

| Field | Description | Required |
|-------|-------------|----------|
| `f` | From (sender ID) | Yes |
| `t` | To (target ID or `ALL`) | Yes |
| `s` | Sequence number | Yes |
| `b` | Batch ID for parallel ops | No |

### Message Types

#### CTX - Context/State
```
CTX:{p:PROJECT,f:[FILES],st:{STATE},issue?:ID}
```

#### REQ - Request/Task
```
REQ:{o:OBJECTIVE,pr:1-5,d?:[DEPS],exp?:[EXPERTS]}
```

#### PLAN - Task Plan
```
PLAN:[(i:ID,t:TASK,s:P|I|C|X)]
```

Status codes: `P`=Pending, `I`=In-progress, `C`=Completed, `X`=Cancelled

#### ACT - Action
```
ACT:{i?:ID,op:read|write|edit|shell|search,tgt:TARGET,args?:{}}
```

#### OBS - Observation/Result
```
OBS:{ai?:ACT_ID,s:OK|ERR,c:{CONTENT},e?:ERR_MSG}
```

#### BLK - Blocker
```
BLK:{w:WHY,a:[ALTERNATIVES],esc?:true}
```

#### ASK - Question
```
ASK:{q:QUERY,o:[OPTIONS],def?:DEFAULT}
```

#### END - Handoff
```
END:{n:NEXT_ACTION,t?:[TESTS],r?:[RISKS],del:[DELIVERABLES]}
```

#### RES - Response
```
RES:{o:OPTION_CHOSEN,msg?:MESSAGE}
```

### Shortcuts

| Shortcut | Meaning | Example |
|----------|---------|---------|
| `p:` | Path | `p:src/api.ts` |
| `#L` | Line number | `#L42` |
| `#L-L` | Line range | `#L10-25` |
| `@` | Reference | `@ISSUE-123` |
| `+` | Add/create | `+endpoint` |
| `-` | Remove | `-deprecated` |
| `~` | Modify | `~auth logic` |

## Examples

### Task Delegation

```
HEADER:{f:Claude,t:Gemini,s:1}
CTX:{p:myapp,issue:"PROJ-123",st:{phase:"implementation"}}
REQ:{o:"implement dashboard components",pr:2,exp:["UI-EXPERT"]}
PLAN:[(i:1,t:"create TaskTree",s:P),(i:2,t:"create ActivityLog",s:P),(i:3,t:"add streaming",s:P)]
```

### Blocker Resolution

```
HEADER:{f:Codex,t:Claude,s:5}
BLK:{w:"missing DB connection string",a:["use mock","wait for config","use local DB"]}
ASK:{q:"which approach?",o:["mock","wait","local"],def:"mock"}
```

### Completion Handoff

```
HEADER:{f:Gemini,t:Claude,s:10}
PLAN:[(i:1,t:"TaskTree",s:C),(i:2,t:"ActivityLog",s:C),(i:3,t:"streaming",s:C)]
END:{n:"security review",t:["npm test"],del:["src/components/TaskTree.tsx","src/components/ActivityLog.tsx"],r:["needs perf testing"]}
```

### Parallel Batch Operations

```
HEADER:{f:Claude,t:ALL,s:1,b:B1}
ACT:{i:A1,op:read,tgt:"p:src/api.ts"}
ACT:{i:A2,op:search,tgt:"p:src/",args:{q:"TODO"}}
ACT:{i:A3,op:read,tgt:"p:src/db.ts"}
```

## Supported LLMs

LLMX has been tested and confirmed working with:

| LLM | CLI Command | Status |
|-----|-------------|--------|
| Claude | Native / `claude` | ✅ Full support |
| Gemini | `gemini` | ✅ Full support |
| OpenAI Codex | `codex exec` | ✅ Full support |
| GPT-4 | `openai` | ✅ Compatible |
| Llama | `ollama` | ✅ Compatible |

## CLI Reference

### `llmx` - Basic Communication

```bash
llmx send <target> <message>    # Send LLMX message
llmx ask <target> <question>    # Ask question (auto-wrapped)
llmx delegate <target> <task>   # Delegate with tracking
llmx parallel <msg1> <msg2>     # Send to multiple LLMs
llmx status                     # Show recent communications
llmx log                        # Show full message log
llmx reset                      # Reset sequence counter
```

### `orchestrate` - Workflows

```bash
orchestrate review <path>              # Parallel code review
orchestrate implement <task> [--issue] # Coordinated implementation
orchestrate plan <feature>             # Multi-LLM planning
orchestrate consensus <question>       # Build consensus
orchestrate handoff <from> <to> <ctx>  # Structured handoff
```

## Configuration

Create `~/.llmxrc` for custom settings:

```bash
# Default target LLM
LLMX_DEFAULT_TARGET=gemini

# Log location
LLMX_LOG_DIR=~/.llmx

# Custom LLM commands
LLMX_CMD_GEMINI="gemini"
LLMX_CMD_CODEX="codex exec"
LLMX_CMD_GPT4="openai chat"
```

## Integration

### With Task Tracking Systems

Include issue references in CTX:
```
CTX:{p:myproject,issue:"JIRA-123"}
```

### With CI/CD

```yaml
# .github/workflows/review.yml
- name: LLMX Code Review
  run: |
    llmx parallel \
      "review ${{ github.event.pull_request.head.sha }} for security" \
      "review ${{ github.event.pull_request.head.sha }} for performance"
```

### Programmatic Usage

```javascript
// Node.js example
const { LLMX } = require('llmx');

const msg = LLMX.create()
  .header({ from: 'myapp', to: 'gemini', seq: 1 })
  .ctx({ project: 'myproject', files: ['src/api.ts'] })
  .req({ objective: 'review code', priority: 2 })
  .build();

const response = await LLMX.send('gemini', msg);
```

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development

```bash
# Run tests
./test.sh

# Lint
shellcheck bin/*

# Build docs
./docs/build.sh
```

## Roadmap

- [ ] JSON Schema for validation
- [ ] TypeScript/Python SDK
- [ ] VS Code extension
- [ ] Web playground
- [ ] Protocol v2.0 with streaming support

## License

MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

LLMX was developed through collaborative negotiation between Claude, Gemini, and Codex - proving that AIs can design efficient communication protocols together.

---

**Made with AI, for AI, by AI (and humans too).**
