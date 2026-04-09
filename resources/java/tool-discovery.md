# Repository Tool Discovery

**Copilot scans and discovers:**

1. **Build tool detection:**
   - Scan: `pom.xml`, `build.gradle`, `build.gradle.kts`, `settings.gradle`, `settings.gradle.kts`, `.mvn/`, `gradlew`, `gradlew.bat`
   - Report findings: "Found pom.xml → Project uses Maven"

2. **Test framework detection (REQUIRED: JUnit 5):**
   - Scan: `pom.xml` or `build.gradle` for `junit-jupiter`, `junit-jupiter-api`, `junit-jupiter-engine`, `junit-jupiter-params`
   - Check for test directories: `src/test/java/`
   - Check for test runner config: `surefire-plugin`, `maven-failsafe-plugin` in `pom.xml`; `test` task config in `build.gradle`
   - Report findings: "Found junit-jupiter 5.10.x → Project uses JUnit 5"
   - **If NOT found:** Flag as MISSING REQUIRED TOOL

3. **Static analysis detection (REQUIRED: one of SpotBugs / Checkstyle / Error Prone):**
   - Scan: `pom.xml` or `build.gradle` for `spotbugs`, `checkstyle`, `error-prone`, `pmd`
   - Check for config files: `checkstyle.xml`, `spotbugs-exclude.xml`, `pmd-ruleset.xml`
   - Report findings: "Configured: Checkstyle (google_checks), SpotBugs"
   - **If NOT found:** Flag as MISSING REQUIRED TOOL

4. **Code quality tools (OPTIONAL):**
   - Scan: `pom.xml` or `build.gradle` for `jacoco` (coverage), `spotless` or `google-java-format` (formatting), `sonar` (SonarQube)
   - Scan: `.editorconfig` for indentation settings
   - Report findings: "Configured: JaCoCo (80% line coverage), Spotless (google-java-format)"
   - These are optional - workflow can proceed without them

5. **Project scripts:**
   - Scan: `pom.xml` profiles, `build.gradle` tasks, `Makefile`, `.github/workflows`, `scripts/`
   - Report findings: "Found Maven profiles: dev, test, prod; Gradle tasks: test, integrationTest, check"
   - Extract commands that wrap test/analysis if they exist

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
  Build Tool: Maven (found pom.xml)
  Java: 21 (from pom.xml maven.compiler.release)
  Test Framework: JUnit 5 (junit-jupiter 5.10.x)
  Static Analysis: Checkstyle (google_checks.xml), SpotBugs
  Code Quality: JaCoCo (coverage), Spotless (google-java-format)

Suggested Commands:
  Test execution:
    mvn test                                          # All unit tests
    mvn test -pl module-name                          # Specific module
    mvn test -Dtest=MyClassTest                       # Specific test class
    mvn test -Dtest=MyClassTest#testMethod             # Specific test method
    mvn verify                                        # Unit + integration tests
  
  Static analysis:
    mvn checkstyle:check
    mvn spotbugs:check
  
  Code quality:
    mvn jacoco:report
    mvn spotless:check

  Output Filter Command:
    <test-command> 2>&1 | Select-String -Pattern   # PowerShell (Windows)
    # OR
    <test-command> 2>&1 | grep -E                   # bash/zsh (Unix/macOS)

⚠️ VALIDATION CHECK:

Checking for REQUIRED tools:
  ✅ JUnit 5: Found (junit-jupiter in pom.xml)
  ✅ Static Analysis: Found (checkstyle-maven-plugin)

OR (if missing):

⚠️ MISSING REQUIRED TOOLS:
  ❌ JUnit 5: NOT FOUND in project configuration
  ❌ Static Analysis: NOT FOUND in project configuration

RECOMMENDATION:
  These tools are REQUIRED for the TDD workflow:
  
  1. JUnit 5 (test execution) - Add to pom.xml:
     <dependency>
       <groupId>org.junit.jupiter</groupId>
       <artifactId>junit-jupiter</artifactId>
       <version>5.10.2</version>
       <scope>test</scope>
     </dependency>

  2. Mockito (mocking) - Add to pom.xml:
     <dependency>
       <groupId>org.mockito</groupId>
       <artifactId>mockito-core</artifactId>
       <version>5.11.0</version>
       <scope>test</scope>
     </dependency>

  3. Checkstyle / SpotBugs (static analysis) - Add plugin to pom.xml

After installing, I can re-scan to generate proper commands.

Should I:
  A) Proceed with available tools only (NOT RECOMMENDED - missing required tools)
  B) Wait for you to install missing tools, then re-run Tool Discovery
  C) Show installation commands and wait

Questions:
  1. Use "mvn test" for all tests? (Yes/modify)
  2. Any custom flags or coverage thresholds to add?
  3. Prefer Maven wrapper (mvnw) or direct mvn commands?

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
