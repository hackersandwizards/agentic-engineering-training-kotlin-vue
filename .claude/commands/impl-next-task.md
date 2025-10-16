Implement the next available task using orchestrated workflow with mandatory subagent coordination.

This command delegates to the workflow-orchestrator subagent for systematic progression through the optimal TDD workflow, ensuring all mandatory subagents are properly utilized and 100/100 quality standards are achieved.

## 🎯 Orchestrated Implementation Approach

### **MANDATORY: Start with Workflow Orchestrator**

All development task execution MUST begin with workflow orchestrator guidance:

```bash
# PRIMARY COMMAND: Delegate to workflow-orchestrator
Task --subagent_type workflow-orchestrator --prompt "Analyze current project state and guide me through implementing the next available task. Provide JSON guidance for optimal workflow progression including required MCP commands, mandatory subagents, and quality gates."
```

**Why Orchestrator First:**
- Provides systematic 4-phase development process
- Ensures proper subagent coordination sequence
- Enforces quality gates and completion criteria
- Prevents workflow inefficiencies and anti-patterns
- Guarantees 100/100 quality standard compliance

### **Orchestrator-Managed Workflow Phases**

The workflow-orchestrator will guide you through:

#### **Phase 0: Conversation Setup**
- Context assessment and cleanup recommendations
- Project state evaluation

#### **Phase 1: Task Setup (TaskMaster Integration)**
- Task selection and priority analysis
- Requirements review and validation
- Task activation and persona selection

#### **Phase 2: Code Analysis & Research (Explore + Mandatory Subagents)**
- **Phase 2.1**: Explore subagent → Fast codebase reconnaissance, file discovery, pattern location
- **Phase 2.2**: Mandatory subagents (with Explore context):
  - **documentation-researcher** → Internal docs priority, ADRs, architectural decisions
  - **pattern-analyzer** → Existing code patterns, conventions, conformance guidelines
  - **architecture-advisor** → CUPID compliance, SCS patterns, design validation
- Structure exploration and issue identification

#### **Phase 3: TDD Implementation (Rigorous Cycle)**
- **Phase 3a (RED)**: quality-assurance-expert → Test requirements, BDD scenarios
- **Phase 3b (GREEN)**: Minimal implementation with pattern conformance
- **Phase 3c (REFACTOR)**: Clean code until quality = 100/100
- **Phase 3d (DOCUMENT)**: Task updates and knowledge capture
- **Phase 3e (MEMORY)**: Pattern and decision storage
- **Phase 3f (COMMIT)**: Atomic commits with validation

#### **Phase 4: Validation & Completion (Multi-MCP Integration)**
- **quality-assurance-expert** → Final coverage validation
- **review-critic** → Comprehensive implementation review
- **architecture-advisor** → Final compliance checks
- Integration testing and task completion

### **Subagent Coordination Protocol**

**🚨 CRITICAL: DO NOT manually invoke subagents**

The workflow-orchestrator manages all subagent coordination including:

- **Discovery Agent** (Phase 2.1):
  - `explore` → Fast codebase reconnaissance before specialized analysis

- **Mandatory Subagents** (enforced at appropriate phases):
  - `documentation-researcher` (Phase 2.2, uses Explore context)
  - `pattern-analyzer` (Phase 2.2, uses Explore context)
  - `architecture-advisor` (Phase 2.2, uses Explore context)
  - `quality-assurance-expert` (Phase 3a)
  - `review-critic` (Phase 4)

- **MCP Integration** (orchestrator coordinates):
  - Explore agent for fast file discovery
  - TaskMaster MCP for task management
  - JetBrains MCP for file operations
  - Sequential MCP for complex debugging

### **Quality Assurance Integration**

The orchestrator enforces:

- **Local Quality Gates**: Unit tests, lint, build, CUPID validation
- **Pre-Merge Gates**: Integration tests, architecture compliance
- **Pre-Deploy Gates**: E2E tests, performance, security validation

**Quality Gate Commands** (orchestrator specifies in JSON response):
```bash
# Backend validation
./gradlew unitTest integrationTest detekt build

# Frontend validation
npm run install lint unitTest build
```

### **Anti-Pattern Prevention**

The workflow-orchestrator prevents:

- ❌ Code before tests (RED before GREEN violation)
- ❌ Skipping pattern analysis before new code
- ❌ Manual subagent management (always orchestrator-coordinated)
- ❌ Quality gate bypassing (blocks advancement until 100/100)
- ❌ Incomplete TDD cycles
- ❌ Missing mandatory subagents

### **Success Verification**

After workflow-orchestrator completes guidance:

1. **Verify All Mandatory Subagents Used:**
   - documentation-researcher ✅
   - pattern-analyzer ✅
   - architecture-advisor ✅
   - quality-assurance-expert ✅
   - review-critic ✅

2. **Confirm Quality Gates Executed:**
   - Local validation commands run ✅
   - All tests passing ✅
   - Quality score = 100/100 ✅

3. **Validate Task Completion:**
   - Implementation matches requirements ✅
   - Architecture compliance verified ✅
   - Changes committed with proper attribution ✅

### **Next Steps After Completion**

1. Task marked as complete by orchestrator
2. Ready for next orchestrated task iteration
3. Knowledge captured for future reference

**🎯 Remember**: This command is a delegation framework - the workflow-orchestrator provides the actual step-by-step guidance with specific MCP commands and subagent coordination.
