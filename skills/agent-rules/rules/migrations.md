# `migrations.md` — the generated rule

Applies **only when the project has a DB**. Generalize the specifics below to the project's actual migration tooling.

Local dev is push-based; deployed environments are migration-based (in JS: Drizzle's `db:push` / `db:generate` / `db:migrate`). Generate the migration once the shape is final, and it lands **in the same commit** as the schema change — a schema edit without its migration silently never reaches deployed environments.

Never edit a committed migration; add a new one. The deploy pipeline runs the migrations against that environment's database before building.
