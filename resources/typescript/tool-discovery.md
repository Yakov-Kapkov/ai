````markdown
# Repository Tool Discovery

**Copilot scans and discovers:**

1. **Package manager detection:**
   - Scan: `package.json`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `bun.lockb`
   - Report findings: "Found yarn.lock → Project uses yarn"

2. **Test framework detection (REQUIRED: Jest or Vitest):**
   - Scan: `jest.config.ts`, `jest.config.js`, `jest.config.mjs`, `vitest.config.ts`, `vitest.config.js`
   - Check `package.json`: `scripts`, `jest`, `vitest` keys; `devDependencies` for `jest`, `vitest`, `@jest/core`, `@vitest/ui`
   - Report findings: "Found jest.config.ts → Project uses Jest with ts-jest"
   - **If NOT found:** Flag as MISSING REQUIRED TOOL

3. **Type checking detection (REQUIRED: TypeScript / tsc):**
   - Scan: `tsconfig.json`, `tsconfig.*.json` (e.g. `tsconfig.build.json`, `tsconfig.test.json`)
   - Check `package.json` `devDependencies` for `typescript`; check `scripts` for `tsc`, `type-check`, `typecheck`
   - Report findings: "Found tsconfig.json → strict mode enabled, target ES2022"
   - **If NOT found:** Flag as MISSING REQUIRED TOOL

4. **Code quality tools (OPTIONAL):**
   - Scan: `.eslintrc`, `.eslintrc.js`, `.eslintrc.json`, `eslint.config.js`, `eslint.config.ts` for ESLint
   - Scan: `.prettierrc`, `.prettierrc.js`, `.prettierrc.json`, `prettier.config.js` for Prettier
   - Scan: `.husky/`, `.lintstagedrc`, `lint-staged` key in `package.json` for pre-commit hooks
   - Report findings: "Configured: ESLint (typescript-eslint), Prettier (semi: false, singleQuote: true)"
   - These are optional - workflow can proceed without them

5. **Project scripts:**
   - Scan: `package.json[scripts]`, `Makefile`, `.github/workflows`, `scripts/`
   - Report findings: "Found npm scripts: test, test:unit, test:coverage, type-check, lint"
   - Extract commands that wrap jest/vitest/tsc if they exist

6. **OS / shell detection (REQUIRED for output filtering):**
   - Detect the operating system and shell available in the project environment.
   - Windows (PowerShell): use `Select-String -Pattern`
   - Unix/macOS (bash/zsh): use `grep -E`
   - Record the filter command as a single-line pipe expression, e.g.:
     - PowerShell: `Select-String -Pattern`
     - bash/zsh: `grep -E`
   - This value is written to `project-tools.md` under `Output Filter Command`
     and used by all agents when running test commands.

**Copilot presents discovery report:**
```
Repository Discovery Report
Generated: [timestamp]

Detected Tools:
  Package Manager: npm (found package-lock.json)
  TypeScript: 5.4.x (from package.json devDependencies)
  Test Framework: Jest (jest.config.ts, ts-jest preset)
  Type Checking: tsc (tsconfig.json, strict: true)
  Code Quality: ESLint (typescript-eslint), Prettier, Husky + lint-staged

Suggested Commands:
  Test execution:
    npm test                                    # All tests
    npm test -- src/module/module.test.ts       # Specific file
    npm test -- --coverage                      # With coverage
    npm test -- --watch                         # Watch mode
  
  Type checking:
    npx tsc --noEmit
  
  Code quality:
    npm run lint
    npm run format

  Output Filter Command:
    <test-command> 2>&1 | Select-String -Pattern   # PowerShell (Windows)
    # OR
    <test-command> 2>&1 | grep -E                   # bash/zsh (Unix/macOS)

⚠️ VALIDATION CHECK:

Checking for REQUIRED tools:
  ✅ Jest/Vitest: Found (jest.config.ts)
  ✅ TypeScript: Found (tsconfig.json)

OR (if missing):

⚠️ MISSING REQUIRED TOOLS:
  ❌ Jest/Vitest: NOT FOUND in project configuration
  ❌ TypeScript: NOT FOUND in project configuration

RECOMMENDATION:
  These tools are REQUIRED for the TDD workflow:
  
  1. Jest + ts-jest (test execution) - Install:
     npm install --save-dev jest ts-jest @types/jest
     # OR for Vitest:
     npm install --save-dev vitest @vitest/coverage-v8
  
  2. TypeScript + tsc (type checking) - Install:
     npm install --save-dev typescript

After installing, I can re-scan to generate proper commands.

Should I:
  A) Proceed with available tools only (NOT RECOMMENDED - missing required tools)
  B) Wait for you to install missing tools, then re-run Tool Discovery
  C) Show installation commands and wait

Questions:
  1. Use "npm test" for all tests? (Yes/modify)
  2. Any custom flags or coverage thresholds to add?
  3. Prefer npm scripts or direct npx commands?

Ready to save these commands to project-tools.md?
```

**Human responses:**
- ✅ "Approved" / "Yes" / "Save" → Save commands, continue with the current task
- 🔧 "Use [different command]" → Update and save
- 🔄 "Add [command]" → Add to list and save
- ⚠️ "Install missing" / "Option B" / "Option C" → Handle missing tools first

**After approval:**
- Create `project-tools.md` with approved commands
- Confirm: "Project tool discovery complete ✓"
- **✋ STOP and ask:** "Ready to continue with the current task?"
- **WAIT for explicit approval** before proceeding with the current task

````
