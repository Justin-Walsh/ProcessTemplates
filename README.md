# ProcessTemplates
Octopus Process Template automation sandbox.

## What This PoC Does

This repository is a proof of concept for keeping simple deployment scripts and Octopus process templates in sync.

When a root-level Bash script changes, the automation generates or updates a matching `.ocl` file under `.octopus/process-templates/`.

Examples:

- `deploy.api.sh` becomes `.octopus/process-templates/deploy-api.ocl`
- `deploy-api-prod.sh` becomes `.octopus/process-templates/deploy-api-prod.ocl`

For new templates, the generated OCL uses a normalized Octopus-safe name:

- the top-level template name is lowercased and `.` becomes `-`
- the step slug is also lowercased and `.` becomes `-`
- the visible step name still keeps the original script filename

## How It Works

1. A changed root-level `*.sh` file is picked up by the sync script.
2. The script is converted into an Octopus `Octopus.Script` step with the Bash body stored inline.
3. If the target `.ocl` file does not exist yet, a new template is created.
4. If the target `.ocl` file already exists, only the `Octopus.Action.Script.ScriptBody` is replaced.

That means existing parameters, descriptions, custom properties, and surrounding OCL structure are preserved.

## Failsafes

- The generated `.ocl` filename is normalized so Octopus does not see invalid slugs like `deploy.api`.
- The sync fails if two root-level scripts would normalize to the same template name, such as `deploy.api.sh` and `deploy-api.sh`.
- The sync fails if an existing `.ocl` file cannot be updated safely and unambiguously.
- Generated output must pass the repo-local OCL validator before the automation would open or update a PR.

## Current Limits

- This is still a PoC, not a full production workflow.
- Only root-level `*.sh` files are in scope.
- The validator checks the repo's accepted OCL shape and escaping rules.
- It does not yet prove that Octopus will accept every generated file in a live environment.
