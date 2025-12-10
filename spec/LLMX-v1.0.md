# LLMX Protocol Specification v1.0

## Abstract

LLMX (LLM Exchange) is a lightweight, token-efficient protocol designed for structured communication between Large Language Models. This specification defines the message format, semantics, and processing rules for LLMX v1.0.

## 1. Introduction

### 1.1 Purpose

LLMX addresses the need for efficient inter-LLM communication in multi-agent systems. As AI orchestration becomes more common, the overhead of natural language communication between agents becomes significant. LLMX provides:

- Structured message format with defined semantics
- Token efficiency through compression and abbreviation
- Clear handoff mechanisms for task coordination
- Support for parallel and sequential workflows

### 1.2 Design Principles

1. **Minimal** - Use the fewest tokens necessary
2. **Unambiguous** - Clear semantics, no interpretation needed
3. **Extensible** - Support custom message types
4. **Human-readable** - Developers can understand messages
5. **LLM-native** - Easy for LLMs to generate and parse

## 2. Message Format

### 2.1 General Structure

An LLMX message consists of a required HEADER followed by one or more message blocks:

```
HEADER:{field:value,...}
BLOCK1:{field:value,...}
BLOCK2:{field:value,...}
...
```

### 2.2 Syntax Rules

1. **Field names** are lowercase alphanumeric with underscores
2. **String values** use double quotes: `"value"`
3. **Arrays** use brackets: `[item1,item2]`
4. **Objects** use braces: `{key:value}`
5. **Optional fields** are denoted with `?` in specs
6. **Whitespace** between blocks is ignored
7. **Line breaks** are allowed between blocks

### 2.3 Data Types

| Type | Syntax | Example |
|------|--------|---------|
| String | `"text"` | `"review code"` |
| Number | `123` | `42` |
| Boolean | `true\|false` | `true` |
| Array | `[a,b,c]` | `["file1","file2"]` |
| Object | `{k:v}` | `{status:"ok"}` |
| Enum | `A\|B\|C` | `P\|I\|C\|X` |

## 3. Message Types

### 3.1 HEADER

**Required** on every message. Identifies sender, recipient, and sequence.

```
HEADER:{f:SENDER,t:TARGET,s:SEQUENCE,b?:BATCH_ID}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `f` | String | Yes | Sender identifier |
| `t` | String | Yes | Target identifier or `ALL` |
| `s` | Number | Yes | Sequence number (monotonic) |
| `b` | String | No | Batch ID for parallel operations |

**Example:**
```
HEADER:{f:Claude,t:Gemini,s:1}
HEADER:{f:Orchestrator,t:ALL,s:42,b:B1}
```

### 3.2 CTX - Context

Establishes shared context and state.

```
CTX:{p:PROJECT,f?:[FILES],st?:{STATE},issue?:ISSUE_ID}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `p` | String | Yes | Project identifier |
| `f` | Array | No | Relevant file paths |
| `st` | Object | No | State key-value pairs |
| `issue` | String | No | Associated issue/ticket ID |

**Example:**
```
CTX:{p:myapp,f:["src/api.ts","src/db.ts"],st:{phase:"P1",env:"dev"},issue:"PROJ-123"}
```

### 3.3 REQ - Request

Requests action from the recipient.

```
REQ:{o:OBJECTIVE,pr:PRIORITY,d?:[DEPENDENCIES],exp?:[EXPERTS]}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `o` | String | Yes | Objective description |
| `pr` | Number | Yes | Priority (1=critical, 5=low) |
| `d` | Array | No | Dependency IDs |
| `exp` | Array | No | Required expert reviewers |

**Example:**
```
REQ:{o:"implement user authentication",pr:2,d:["PROJ-100"],exp:["SECURITY-EXPERT"]}
```

### 3.4 PLAN - Task Plan

Defines ordered steps with status tracking.

```
PLAN:[(i:ID,t:TASK,s:STATUS),...]
```

| Field | Type | Description |
|-------|------|-------------|
| `i` | Number/String | Step identifier |
| `t` | String | Task description |
| `s` | Enum | Status: `P\|I\|C\|X` |

**Status Values:**
- `P` - Pending (not started)
- `I` - In-progress (currently executing)
- `C` - Completed (successfully finished)
- `X` - Cancelled/Failed (will not complete)

**Example:**
```
PLAN:[(i:1,t:"analyze requirements",s:C),(i:2,t:"implement core",s:I),(i:3,t:"write tests",s:P)]
```

### 3.5 ACT - Action

Declares an action to be executed.

```
ACT:{i?:ID,op:OPERATION,tgt:TARGET,args?:{ARGUMENTS}}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `i` | String | No | Action identifier (for tracking) |
| `op` | Enum | Yes | Operation type |
| `tgt` | String | Yes | Target path/resource |
| `args` | Object | No | Operation-specific arguments |

**Operations:**
- `read` - Read file/resource
- `write` - Create new file
- `edit` - Modify existing file
- `shell` - Execute shell command
- `search` - Search codebase
- `spawn` - Spawn sub-agent

**Example:**
```
ACT:{i:A1,op:edit,tgt:"p:src/auth.ts#L42",args:{action:"add validation"}}
ACT:{op:shell,tgt:"npm test"}
```

### 3.6 OBS - Observation

Reports the result of an action.

```
OBS:{ai?:ACT_ID,s:STATUS,c:{CONTENT},e?:ERROR_MSG}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `ai` | String | No | Action ID being reported |
| `s` | Enum | Yes | Status: `OK\|ERR` |
| `c` | Object | Yes | Result content |
| `e` | String | No | Error message (if ERR) |

**Example:**
```
OBS:{ai:A1,s:OK,c:{lines:45,modified:true}}
OBS:{ai:A2,s:ERR,e:"file not found: src/missing.ts"}
```

### 3.7 BLK - Blocker

Reports an impediment requiring resolution.

```
BLK:{w:WHY,a:[ALTERNATIVES],esc?:ESCALATE}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `w` | String | Yes | Reason for blockage |
| `a` | Array | Yes | Alternative approaches |
| `esc` | Boolean | No | Escalate to human |

**Example:**
```
BLK:{w:"missing API credentials",a:["use mock","wait for config","skip feature"],esc:true}
```

### 3.8 ASK - Question

Requests decision or clarification.

```
ASK:{q:QUESTION,o:[OPTIONS],def?:DEFAULT}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `q` | String | Yes | Question text |
| `o` | Array | Yes | Available options |
| `def` | String | No | Default/recommended option |

**Example:**
```
ASK:{q:"which auth method?",o:["JWT","session","OAuth2"],def:"JWT"}
```

### 3.9 END - Handoff

Signals completion and hands off to next step.

```
END:{n:NEXT_ACTION,t?:[TESTS],r?:[RISKS],del:[DELIVERABLES]}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `n` | String | Yes | Next action needed |
| `t` | Array | No | Tests to run |
| `r` | Array | No | Risks to note |
| `del` | Array | Yes | Deliverable file paths |

**Example:**
```
END:{n:"security review",t:["npm test","npm run lint"],r:["needs load testing"],del:["src/auth.ts","src/auth.test.ts"]}
```

### 3.10 RES - Response

Acknowledges or responds to a message.

```
RES:{o:OPTION,msg?:MESSAGE}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `o` | String | Yes | Selected option or ACK/NACK |
| `msg` | String | No | Additional message |

**Example:**
```
RES:{o:"ACK",msg:"proceeding with implementation"}
RES:{o:"JWT",msg:"will use RS256 signing"}
```

## 4. Shortcuts and Abbreviations

### 4.1 Path Shortcuts

| Shortcut | Expansion | Example |
|----------|-----------|---------|
| `p:` | File path | `p:src/api.ts` |
| `#L` | Line number | `p:file.ts#L42` |
| `#L-L` | Line range | `p:file.ts#L10-25` |
| `^` | Parent directory | `^/src` |

### 4.2 Operation Shortcuts

| Shortcut | Meaning |
|----------|---------|
| `+` | Add/create |
| `-` | Remove/delete |
| `~` | Modify/change |
| `?` | Query/check |
| `!` | Force/important |
| `*` | All/wildcard |
| `@` | Reference |

## 5. Batch Operations

### 5.1 Parallel Execution

Multiple actions can be batched for parallel execution using the `b` (batch) field in HEADER:

```
HEADER:{f:Claude,t:ALL,s:1,b:B1}
ACT:{i:A1,op:read,tgt:"p:file1.ts"}
ACT:{i:A2,op:read,tgt:"p:file2.ts"}
ACT:{i:A3,op:search,tgt:"p:src/",args:{q:"TODO"}}
```

### 5.2 Batch Responses

Responses to batched operations reference the action IDs:

```
HEADER:{f:Gemini,t:Claude,s:2,b:B1}
OBS:{ai:A1,s:OK,c:{lines:100}}
OBS:{ai:A3,s:OK,c:{matches:5}}
OBS:{ai:A2,s:OK,c:{lines:50}}
```

Note: Responses may arrive out of order.

## 6. Protocol Flow

### 6.1 Request-Response

```
Agent A                    Agent B
   |                          |
   |  HEADER + REQ            |
   |------------------------->|
   |                          |
   |  HEADER + RES            |
   |<-------------------------|
   |                          |
```

### 6.2 Task Delegation

```
Orchestrator              Worker
   |                          |
   |  HEADER + CTX + REQ      |
   |  + PLAN                  |
   |------------------------->|
   |                          |
   |  HEADER + PLAN (updated) |
   |<-------------------------|
   |                          |
   |  HEADER + END            |
   |<-------------------------|
   |                          |
```

### 6.3 Blocker Resolution

```
Worker                  Orchestrator              Human
   |                          |                      |
   |  HEADER + BLK + ASK      |                      |
   |------------------------->|                      |
   |                          |  (if esc:true)       |
   |                          |--------------------->|
   |                          |                      |
   |                          |  Decision            |
   |                          |<---------------------|
   |  HEADER + RES            |                      |
   |<-------------------------|                      |
   |                          |                      |
```

## 7. Error Handling

### 7.1 Error Responses

Use `OBS` with `s:ERR` for operation failures:

```
OBS:{ai:A1,s:ERR,e:"permission denied"}
```

### 7.2 Protocol Errors

For malformed messages, respond with:

```
RES:{o:"NACK",msg:"parse error: missing required field 'o' in REQ"}
```

### 7.3 Unknown Message Types

Unknown message types should be ignored with a warning:

```
RES:{o:"WARN",msg:"unknown message type: CUSTOM ignored"}
```

## 8. Extensibility

### 8.1 Custom Message Types

Custom message types can be added using the pattern:

```
X_TYPENAME:{field:value,...}
```

The `X_` prefix indicates an extension. Receivers that don't understand the type should ignore it.

### 8.2 Custom Fields

Custom fields in standard messages use the `x_` prefix:

```
REQ:{o:"task",pr:2,x_team:"frontend",x_deadline:"2024-01-15"}
```

## 9. Security Considerations

### 9.1 Input Validation

All string inputs should be validated and sanitized before use in:
- Shell commands
- File paths
- Database queries

### 9.2 Path Traversal

File paths should be validated to prevent directory traversal attacks.

### 9.3 Injection Prevention

The `args` field in ACT messages should never be passed directly to shell execution without sanitization.

## 10. Conformance

### 10.1 Required Support

A conformant LLMX v1.0 implementation MUST support:
- HEADER parsing and generation
- All standard message types (CTX, REQ, PLAN, ACT, OBS, BLK, ASK, END, RES)
- All shortcut expansions
- Batch operations

### 10.2 Optional Support

The following are optional:
- Custom message types (X_*)
- Custom fields (x_*)
- Streaming responses

## Appendix A: Grammar (EBNF)

```ebnf
message     = header , { block } ;
header      = "HEADER:" , object ;
block       = type , ":" , ( object | array ) ;
type        = letter , { letter | digit | "_" } ;
object      = "{" , [ pair , { "," , pair } ] , "}" ;
pair        = key , ":" , value ;
key         = letter , { letter | digit | "_" } ;
value       = string | number | boolean | array | object ;
string      = '"' , { char } , '"' ;
number      = [ "-" ] , digit , { digit } , [ "." , digit , { digit } ] ;
boolean     = "true" | "false" ;
array       = "[" , [ value , { "," , value } ] , "]" ;
```

## Appendix B: Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2024-12 | Initial specification |

---

*LLMX Protocol Specification v1.0*
*Copyright 2025 - MIT License*
