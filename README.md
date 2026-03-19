# ProcessTemplates
Octopus ProcessTemplate automation sandbox

## OCL Sync Contract

Root-level `*.sh` changes trigger GitHub Actions generation for matching OCL files under `.octopus/process-templates/`.

For new templates, the naming contract is:

- `deploy.api.sh` -> `.octopus/process-templates/deploy.api.ocl`
- `deploy-api-prod.sh` -> `.octopus/process-templates/deploy-api-prod.ocl`
- top-level template name = source filename without `.sh`, lowercased, with `.` replaced by `-`
- step slug = source filename lowercased with `.` replaced by `-`

The sync step rejects root-level `*.sh` files that would normalize to the same top-level template name, such as `deploy.api.sh` and `deploy-api.sh`.

If the target `.ocl` file already exists, the generator preserves the existing file and updates only `Octopus.Action.Script.ScriptBody` inside a single unambiguous Bash `Octopus.Script` action. Parameters, descriptions, custom properties, and surrounding structure are left unchanged.

Generation is validator-first. The workflow only opens or updates an automation PR after generated or updated OCL passes the repo-local structural validator.

The current validator checks the repository's accepted OCL shape and escaping rules, but it does not yet prove Octopus acceptance against an authoritative parser or live Octopus environment.
