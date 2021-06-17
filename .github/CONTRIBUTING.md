## Branches
There are two main branches. `master` is the production branch which every accepted change is merged in. `development` is the branch that has features to be proposed to be merged in `master` after testing in a remote machine in `Staging` environment.
Every issue should have its own branch for the sake of modularity.

## Issues and PRs
All issues should be handled (if it's related to code) in a seperate branch and as soon as a change is made, a new PR should be opened.

## Committing
  Must be one of the following:

  feat: A new feature

  fix: A bug fix

  docs: Documentation only changes

  style: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)

  refactor: A code change that neither fixes a bug nor adds a feature

  perf: A code change that improves performance

  test: Adding missing or correcting existing tests

  chore: Changes to the build process or auxiliary tools and libraries such as documentation generation

  BREAKING CHANGE: will create a major version

  Here is an example of the release type that will be done based on a commit messages:

| Commit message                                                                                                                                                                                   | Release type  |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------- |
| `fix(pencil): stop graphite breaking when too much pressure applied`                                                                                                                             | Patch Release |
| `feat(pencil): add 'graphiteWidth' option`                                                                                                                                                       | Minor Release |
| `perf(pencil): remove graphiteWidth option`<br><br>`BREAKING CHANGE: The graphiteWidth option has been removed.`<br>`The default graphite width of 10mm is always used for performance reasons.` | Major Release |


## Setup
Simply create a local.env and fill it like [example](../example.env) `docker-compose up -d` and connect to `mtasa://127.0.0.1:22003` on your local computer.
