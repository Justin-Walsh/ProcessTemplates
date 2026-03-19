# OCL Output Contract

- Output file path: `.octopus/process-templates/<source-basename-without-.sh>.ocl`
- Top-level `name`: source basename without `.sh`
- Top-level `description`: `<top-level name> process template`
- Step `name`: source filename including `.sh`
- Step slug: source filename lowercased with every `.` replaced by `-`
- Script body: one quoted OCL string using `\n`, `\"`, and `\\` escaping
- MVP output must not rely on multiline OCL heredoc syntax
