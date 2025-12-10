# LLMX Workflow Patterns

## Pattern 1: Divide and Conquer

Split work between LLMs based on their strengths.

```
┌─────────────────┐
│   Orchestrator  │
│    (Claude)     │
└────────┬────────┘
         │
    ┌────┴────┐
    ▼         ▼
┌───────┐ ┌───────┐
│Gemini │ │ Codex │
│(UI/UX)│ │(Logic)│
└───────┘ └───────┘
```

### Example: Full-Stack Feature

```bash
# Step 1: Gemini designs the UI
llmx delegate gemini "design user profile page with edit functionality" -i FEAT-100

# Step 2: Codex implements the API
llmx delegate codex "create CRUD endpoints for user profile" -i FEAT-100

# Step 3: Parallel review
orchestrate review src/
```

## Pattern 2: Chain of Experts

Sequential handoffs through specialized processing.

```
Architect → Designer → Implementer → Reviewer
  (Plan)    (Design)    (Code)       (QA)
```

### Example: New Feature Pipeline

```bash
# 1. Architecture planning
llmx ask gemini "Design architecture for real-time notifications: WebSocket vs SSE, data flow, components needed"

# 2. Implementation
llmx delegate codex "Implement notification system based on architecture" -i NOTIF-1

# 3. Review
llmx send gemini 'CTX:{p:app,f:["src/notifications/"]}
REQ:{o:"review notification implementation for scalability and edge cases",pr:2}'
```

## Pattern 3: Consensus Building

Get multiple perspectives before deciding.

```
        Question
           │
    ┌──────┼──────┐
    ▼      ▼      ▼
  LLM1   LLM2   LLM3
    │      │      │
    └──────┼──────┘
           ▼
       Synthesis
```

### Example: Technical Decision

```bash
# Get opinions from all LLMs
orchestrate consensus "For a high-traffic e-commerce site, should we use:
1. Server-side rendering (Next.js)
2. Static generation with client hydration
3. Full SPA with API backend"

# Review responses and make decision
```

## Pattern 4: Iterative Refinement

Progressive improvement through feedback loops.

```
Draft → Review → Revise → Review → Final
  │        │        │        │        │
  └────────┴────────┴────────┴────────┘
```

### Example: Code Quality Loop

```bash
# Initial implementation
llmx delegate codex "implement password validation with strength meter" -i AUTH-50

# Review round 1
llmx send gemini 'CTX:{p:auth,f:["src/validation/password.ts"]}
REQ:{o:"review for security best practices, edge cases, UX",pr:2}'

# Apply feedback and re-review until 10/10
```

## Pattern 5: Parallel Exploration

Explore multiple approaches simultaneously.

```
           Problem
              │
    ┌─────────┼─────────┐
    ▼         ▼         ▼
Approach A Approach B Approach C
    │         │         │
    └─────────┼─────────┘
              ▼
         Best Solution
```

### Example: Performance Optimization

```bash
# Explore approaches in parallel
llmx parallel \
  "analyze React rendering performance, suggest optimizations" \
  "analyze API response times, suggest backend optimizations"

# Or use orchestrate
orchestrate plan "improve page load time from 3s to under 1s"
```

## Pattern 6: Supervisor-Worker

Central coordinator managing multiple workers.

```
      ┌─────────────┐
      │ Supervisor  │
      │  (Claude)   │
      └──────┬──────┘
             │
    ┌────────┼────────┐
    ▼        ▼        ▼
┌───────┐┌───────┐┌───────┐
│Worker1││Worker2││Worker3│
└───────┘└───────┘└───────┘
```

### Example: Large Refactoring

```bash
# Supervisor breaks down work
orchestrate plan "refactor authentication module to use JWT"

# Assign to workers
llmx delegate gemini "update login/signup UI for new auth flow" -i REF-1.1
llmx delegate codex "implement JWT token service" -i REF-1.2
llmx delegate codex "migrate existing sessions to JWT" -i REF-1.3

# Monitor and coordinate
llmx status
```

## Pattern 7: Checkpoint and Resume

Handle long-running tasks with state preservation.

```
Start → Checkpoint → Resume → Checkpoint → Complete
          (save)     (load)     (save)
```

### Example: Migration Task

```bash
# Start migration with checkpointing
llmx send codex 'CTX:{p:migrate,issue:"MIG-100",st:{checkpoint:true}}
REQ:{o:"migrate database schema v1 to v2, checkpoint after each table",pr:1}
PLAN:[(i:1,t:"backup",s:P),(i:2,t:"migrate users",s:P),(i:3,t:"migrate orders",s:P),(i:4,t:"verify",s:P)]'

# If interrupted, resume from checkpoint
llmx send codex 'CTX:{p:migrate,issue:"MIG-100",st:{resume:true,from:2}}
REQ:{o:"continue migration from checkpoint",pr:1}'
```

## Best Practices

### 1. Clear Context
Always provide sufficient context in CTX block:
```
CTX:{p:myapp,issue:"PROJ-123",f:["relevant/files"],st:{phase:"dev",env:"staging"}}
```

### 2. Explicit Priorities
Use priority to indicate urgency:
- `pr:1` - Critical/blocking
- `pr:2` - High priority
- `pr:3` - Normal
- `pr:4` - Low priority
- `pr:5` - Nice to have

### 3. Track Dependencies
Reference related issues and blockers:
```
REQ:{o:"implement feature",pr:2,d:["PROJ-100","PROJ-101"]}
```

### 4. Request Expert Review
Specify required reviewers:
```
REQ:{o:"implement auth",pr:2,exp:["SECURITY-EXPERT","API-EXPERT"]}
```

### 5. Clean Handoffs
Always include deliverables and next steps:
```
END:{n:"deploy to staging",t:["npm test"],del:["src/feature.ts"],r:["needs load testing"]}
```
