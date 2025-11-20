return {
  version = 1;
  enabled = true;
  
  -- Networking Config
  mode = "host", -- Options: "host", "client", "loopback"
  port = 7777,
  target_ip = "127.0.0.1", -- Localhost for testing
  
  -- Debugging
  debug_logging = true,
}