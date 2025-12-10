# Basic LLMX Usage Examples

## Simple Messages

### Send a Review Request
```bash
llmx send gemini 'CTX:{p:myapp,f:["src/auth.ts"]}
REQ:{o:"review for security vulnerabilities",pr:2}'
```

### Ask a Question
```bash
llmx ask codex "What's the best way to implement rate limiting in Node.js?"
```

### Delegate a Task
```bash
llmx delegate gemini "create a login form component" --issue PROJ-42 --priority 2
```

## LLMX Message Examples

### Task Delegation with Full Context
```
HEADER:{f:Claude,t:Gemini,s:1}
CTX:{p:ecommerce,issue:"SHOP-123",f:["src/cart/","src/checkout/"],st:{phase:"implementation"}}
REQ:{o:"implement shopping cart persistence using localStorage",pr:2,exp:["FRONTEND-EXPERT"]}
PLAN:[(i:1,t:"design state structure",s:P),(i:2,t:"implement storage hooks",s:P),(i:3,t:"add cart sync",s:P),(i:4,t:"write tests",s:P)]
```

### Reporting Progress
```
HEADER:{f:Gemini,t:Claude,s:2}
PLAN:[(i:1,t:"design state structure",s:C),(i:2,t:"implement storage hooks",s:I),(i:3,t:"add cart sync",s:P),(i:4,t:"write tests",s:P)]
OBS:{s:OK,c:{files_created:2,lines:145}}
```

### Reporting a Blocker
```
HEADER:{f:Codex,t:Claude,s:5}
BLK:{w:"localStorage quota exceeded on mobile Safari",a:["use IndexedDB instead","implement compression","reduce stored data"]}
ASK:{q:"which approach should I take?",o:["IndexedDB","compression","reduce data"],def:"IndexedDB"}
```

### Handoff on Completion
```
HEADER:{f:Gemini,t:Claude,s:10}
PLAN:[(i:1,t:"design state structure",s:C),(i:2,t:"implement storage hooks",s:C),(i:3,t:"add cart sync",s:C),(i:4,t:"write tests",s:C)]
END:{n:"code review by Codex",t:["npm test","npm run lint"],del:["src/cart/useCart.ts","src/cart/storage.ts","src/cart/__tests__/cart.test.ts"],r:["needs e2e testing"]}
```

### Response/Acknowledgment
```
HEADER:{f:Claude,t:Gemini,s:11}
RES:{o:"ACK",msg:"handoff received, routing to Codex for review"}
```

## Batch Operations

### Parallel File Reads
```
HEADER:{f:Claude,t:Codex,s:1,b:B1}
ACT:{i:A1,op:read,tgt:"p:src/api/routes.ts"}
ACT:{i:A2,op:read,tgt:"p:src/api/middleware.ts"}
ACT:{i:A3,op:search,tgt:"p:src/",args:{q:"TODO|FIXME"}}
```

### Batch Response
```
HEADER:{f:Codex,t:Claude,s:2,b:B1}
OBS:{ai:A1,s:OK,c:{lines:234,exports:["createRouter","useAuth"]}}
OBS:{ai:A3,s:OK,c:{matches:12,files:["routes.ts","utils.ts"]}}
OBS:{ai:A2,s:OK,c:{lines:89,exports:["authMiddleware","rateLimit"]}}
```

## Workflow Examples

### Code Review
```bash
# Parallel review by Gemini (frontend) and Codex (backend)
orchestrate review src/components/Dashboard
```

### Feature Implementation
```bash
# Gemini designs, Codex implements
orchestrate implement "add dark mode toggle" --issue UI-789
```

### Architecture Planning
```bash
# Get plans from all LLMs
orchestrate plan "microservices migration for auth service"
```

### Building Consensus
```bash
# Get opinions and find common ground
orchestrate consensus "Should we use GraphQL or REST for the new API?"
```
