# This file will run before any tests.

# Set up whatever we need to set up before the tests run.
before ->
  process.env.NODE_ENV = "test"
  require "../bin/server"
