# Campus Pulse Serverpod project

This is the backend for Campus Pulse, using Serverpod 4.0.4. The `events` endpoint exposes event listing/details, prototype registrations, organizer event creation, and deterministic study-buddy matching. Endpoint logic depends on `CampusPulseRepository`; `InMemoryCampusPulseRepository` currently seeds prototype events and buddy profiles. All state is temporary and resets when the process restarts.

This phase intentionally has no PostgreSQL configuration, migrations, database persistence, or authentication setup. `prototypeStudentId` is a demo grouping value and is not secure identity. Keep database and auth integration out until explicitly requested.

The user starts the server with `serverpod start`. There is no need to check if the server is running: make the changes and call the `serverpod` MCP tools as needed. If the server is not running, an informative error message will be received from the MCP server. Then STOP and ask the user to start it. NEVER start the server yourself.

While running, `serverpod start` watches for file changes to run incremental code generation and hot reload the running server.

Calling `serverpod generate` directly is not needed, but might be useful to troubleshoot when an incremental generation fails.

ALWAYS use the MCP server instead of the command line. Use the MCP server to:

- `create_migration` and `apply_migrations` for database (after you change data models).
- `create_repair_migration` if the database has drifted out of sync with the migrations.
- `tail_server_logs` to read logs from the server.
- `hot_reload` / `hot_restart` to reload or restart the server. Use `hot_restart` for changes that hot reload cannot apply, such as changes to `main()`.

NEVER edit generated code. The server's `lib/src/generated/` directory and the whole `campus_pulse_client` package are rewritten by the code generator. Change the `.spy.yaml` models, the endpoints, or `lib/server.dart` instead.

Migrations are a narrow exception: the `migration.sql` of a generated migration MAY be edited by hand when the generated SQL would lose data — to add a data transformation, or to reach a destructive change through non-destructive steps. Never touch the other files in the migration directory, and keep the schema the SQL ends up with identical to `definition.sql` — new databases are created from that file and never run `migration.sql`.

Only when the server cannot be started at all, fall back to the CLI in the server package:

- `serverpod generate` to regenerate the client and the generated server code.
- `serverpod create-migration` after changing a model with a `table` (add `--force` for destructive changes). It only writes the migration; `serverpod start` applies pending migrations when it boots the server.

The focused repository unit tests need neither Serverpod startup nor PostgreSQL. Run `dart test test/unit/in_memory_campus_pulse_repository_test.dart` in the server package. Integration tests that start the full Serverpod process may require the project runtime configuration; do not add a database merely to satisfy the prototype unit tests.

Checklist after doing changes, in this order:

- `dart analyze` (CLI)
- `dart format` (CLI)
- `create_migration` and `apply_migrations` (MCP - only if necessary)
- Do `serverpod` MCP `hot_restart` if required (hot reload is done automatically)
- Run tests, if applicable (`dart test` in the server package)
- Check `serverpod` MCP `tail_server_logs` for any issues.

