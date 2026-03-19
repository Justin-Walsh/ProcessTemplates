# OCL Output Contract

- Output file path: `.octopus/process-templates/<normalized-top-level-name>.ocl`
- Top-level `name`: source basename without `.sh`, lowercased, with every `.` replaced by `-`
- Top-level `description`: `<top-level name> process template`
- Step `name`: source filename including `.sh`
- Step slug: source filename lowercased with every `.` replaced by `-`
- Sync must fail if two root-level `*.sh` files normalize to the same top-level `name`
- Script body: one quoted OCL string using `\n`, `\"`, and `\\` escaping
- MVP output must not rely on multiline OCL heredoc syntax
