# Jackal (Anubis Elixir Port) - Bug Fixes & Base Implementation Plan

## Current Issues Found:
- [x] Project compiles with warnings but basic structure exists
- [x] Fix @difficulty undefined module attribute bug in Challenge.generate/0
- [x] Fix unused difficulty variable warning in Challenge.generate/0  
- [x] Remove/fix broken test that calls undefined AnubisPlug.hello/0
- [x] Fix compile-time policy loading issue in AnubisPlug main module
- [x] Add proper configuration setup
- [ ] Add missing cookie/JWT handling for verified clients
- [ ] Implement challenge verification endpoint
- [ ] Add challenge UI (HTML template + JavaScript for proof-of-work)
- [ ] Add comprehensive tests for all modules

## Implementation Plan:

### Phase 1: Fix Critical Bugs (Steps 1-4) ✅ COMPLETE
- [x] Fix Challenge module @difficulty bug and variable usage
- [x] Fix main AnubisPlug module policy loading at compile time
- [x] Replace broken test with proper plug tests
- [x] Add basic configuration in config.exs

### Phase 2: Core Functionality (Steps 5-8)
- [ ] Add cookie/JWT token handling for verified clients
- [ ] Implement challenge verification endpoint
- [ ] Add challenge UI templates and JavaScript
- [ ] Add comprehensive test coverage

### Phase 3: Polish & Documentation (Steps 9-10)
- [ ] Add example usage and documentation
- [ ] Final testing and validation

**Total estimated steps: 10**

## Current Working Components:
✅ Policy engine with rule matching
✅ Default bot policies (good/bad bots)
✅ Basic proof-of-work challenge generation/verification
✅ Plug architecture foundation
✅ All tests passing cleanly
✅ No compile warnings

## Next: Add cookie/JWT handling for verified clients!

