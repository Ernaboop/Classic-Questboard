# Releasing Classic Questboard

`Classic Questboard.toc` is the release-version source. During Alpha its `Version`
field is `MAJOR.MINOR.PATCH-alpha`. The in-game label reads that metadata and
shows, for example, `Alpha v0.13.2` for `0.13.2-alpha`.

For a release, update the TOC version and write one matching entry in
`CHANGELOG.md` and `Data/UpdateHistory.lua`. These history entries use the
numeric part of the TOC version. Run `python tests/run.py` and
`python scripts/check_release.py`. Commit the validated files locally.

When ready to publish, create an **annotated** Git tag matching the TOC exactly
with a `v` prefix, then push the commit and tag:

```sh
git tag -a v0.13.2-alpha -m "Classic Questboard 0.13.2-alpha"
git push origin master
git push origin v0.13.2-alpha
```

The GitHub Actions workflow rejects mismatched tags before publishing. On a
matching tag, the BigWigs packager creates a GitHub release with a zip named
`ClassicQuestboard-v0.13.2-alpha.zip`. The zip still installs as the existing
`Classic Questboard` addon folder, as required by `.pkgmeta` and the TOC name.

CurseForge project 1715617 already has a GitHub webhook. In its project source
settings, choose **Package tagged commits** instead of **Package all commits**.
Then the same pushed version tag triggers its CurseForge alpha build, rather
than a separate hash-named build for every commit. CurseForge manages its own
file naming; the shared tag and TOC metadata make its version identifiable.
The GitHub workflow intentionally does not upload to CurseForge separately,
which would duplicate webhook builds.
