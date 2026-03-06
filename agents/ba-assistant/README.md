# ba-assistant agent

A Business Analyst assistant that helps brainstorm, research, and plan new features.
It does not write or implement code — its role is to think through a feature with you
and produce a clear, actionable plan.

---

## Agent

| Property | Value |
|---|---|
| Model | Claude Sonnet 4.6 |
| User-invokable | ✅ |
| Tools | all enabled (web, search, read, execute, edit, agent, todo, vscode) |

---

## Workflow

1. **Understand** — reads the feature description and asks clarifying questions
   until the goals and constraints are clear.
2. **Brainstorm** — generates a range of ideas and approaches, covering different
   angles and trade-offs.
3. **Research** — gathers relevant information using available tools: web search,
   documentation, repository analysis, or any other applicable method.
4. **Plan** — produces a structured implementation plan: task breakdown,
   dependencies, and any resources or timelines needed.
5. **Collaborate** — refines the plan iteratively based on your feedback until it
   matches your intent.

---

## Usage

Invoke `ba-assistant` with a short description of what you want to build:

```
Add a rate-limiting mechanism to the public API.
```

```
Allow users to export their data as CSV.
```

The agent will ask follow-up questions as needed before producing a plan.

---

## Constraints

- **No implementation.** The agent may write brief code snippets to illustrate a point, but it does not implement the feature. Execution is left to the user or another agent.
- **No assumptions.** If anything in the request is unclear, the agent asks before proceeding.
- **Concise by default.** Responses are kept focused and relevant unless you request more detail.
