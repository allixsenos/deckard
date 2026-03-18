# Changelog

## [0.2.1](https://github.com/allixsenos/deckard/compare/v0.2.0...v0.2.1) (2026-03-18)


### Bug Fixes

* **ci:** trigger release build on release publish instead of tag push ([4c0c7b7](https://github.com/allixsenos/deckard/commit/4c0c7b74249970e531e794f095822d6b2c6a5322))

## [0.2.0](https://github.com/allixsenos/deckard/compare/v0.1.8...v0.2.0) (2026-03-18)


### ⚠ BREAKING CHANGES

* remove MCP server and notification support

### Features

* add diagnostic logging for input freeze investigation ([ba9dcdd](https://github.com/allixsenos/deckard/commit/ba9dcdd3ce2919620a104f647b4f5474cf8d563e))
* move open project button from title bar to sidebar bottom ([f2e789f](https://github.com/allixsenos/deckard/commit/f2e789f3f55b214c8bd1ee42d51f6ce0fa87a06d))


### Bug Fixes

* hide Claude tab terminal until session starts ([ab752d4](https://github.com/allixsenos/deckard/commit/ab752d4a3a681bca2382665ed6c1ef63b622100f))
* prevent Claude tab startup commands from polluting shell history ([ec1e289](https://github.com/allixsenos/deckard/commit/ec1e289efc5bc5fc40e387cee16d2421a7552800))
* resolve project switching by hiding all terminals on switch ([313710a](https://github.com/allixsenos/deckard/commit/313710a30640bf9e6da284a925c29c39e550ede9))
* resolve theme change deadlock by moving config updates off main thread ([4d5cde9](https://github.com/allixsenos/deckard/commit/4d5cde98b493191909f7d85b7a7522dce03ec7cd))


### Code Refactoring

* remove MCP server and notification support ([d33b5d3](https://github.com/allixsenos/deckard/commit/d33b5d31c3f7f963c933b13aaa28fb3c47e8dd74))
