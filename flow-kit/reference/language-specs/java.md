## Java Engineer Reference

### Toolchain
- Lint: `mvn checkstyle:check` or `gradle checkstyleMain` or `spotless check`
- Test: `mvn test` or `gradle test` (JUnit 5)
- Type check: `mvn compile` or `gradle compileJava` (javac -Xlint)
- Build: `mvn package` or `gradle build` or `gradle jar`

### Core Concepts
- **JVM** — Java runs on Java Virtual Machine; enables cross-platform execution
- **Garbage collection** — Automatic memory management; no manual free/delete

### Debug Guide
- Use `jstack <pid>` for thread dumps
- Enable JPDA: `java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n`
- IDE debug: IntelliJ/Eclipse remote attach to JVM

## Breaking Change Detection

Reference: `flow-kit/reference/breaking-change-rules.md`

### Java-specific Patterns

| Pattern | Example | Severity |
|---------|---------|----------|
| Method signature change | `void foo(int)` -> `void foo(String)` | CRITICAL |
| Annotation removal | `@Deprecated` removed | HIGH |
| Class inheritance change | `extends Base` -> `extends Other` | HIGH |
| Interface implementation removed | `implements Foo` removed | HIGH |
| Public class removed | `public class Foo` -> `class Foo` | CRITICAL |

### Detection Commands

```bash
# API signature changes
mvn compile or gradle compileJava

# Dependency audit
mvn dependency:tree | grep -E "^\[INFO\]"

# Lock file change detection
git diff pom.xml or git diff build.gradle
