# Contributing to r7insight_ruby

:+1::tada: Thanks for taking the time to contribute! :tada::+1:

## Requirements

In order to work on this repository you will require:
- ruby version `2.6.5`
- bundle version `2.0.2`
- gem version `3.0.6`
- rvm version `1.29.9`

## Workflow

- Fork repository in GitHub
- Clone your repository fork
- Implement functionality
- `make test` for testing
- Add extra tests and documentation if required
- Push into your fork and create a pull request into the main Rapid7 repository
- Once pull request is approved `make bump-(major|minor|patch)` for bumping versions (use [SemVer](https://semver.org/))
- Push again into the branch
- Pull request should get approved and merged

### Deployment information for Rapid7 developers
- Pull down the merged master which includes the Pull request changes
- `make build`
- `gem push r7insight<VERSION>.gem`
- Create a new release in GitHub with the correct version tag

JetBrains RubyMine was used to develop this gem.  
