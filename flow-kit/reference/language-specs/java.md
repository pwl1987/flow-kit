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
