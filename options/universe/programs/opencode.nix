{ inputs, pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) system;

  opencode = inputs.opencode.packages.${system}.default;
  rime = inputs.rime.packages.${system}.default;
in
{
  environment.systemPackages = [ opencode ];

  universe.hm = [
    {
      home.file.".config/opencode/config.json".text = # json
        ''
          {
            "$schema": "https://opencode.ai/config.json",
            "plugin": [
              "opencode-openai-codex-auth@4.1.0",
              "opencode-gemini-auth@1.2.0"
            ],
            "provider": {
              "openai": {
                "options": {
                  "reasoningEffort": "medium",
                  "reasoningSummary": "auto",
                  "textVerbosity": "medium",
                  "include": [
                    "reasoning.encrypted_content"
                  ],
                  "store": false
                },
                "models": {
                  "gpt-5.2-high": {
                    "name": "GPT 5.2 High (OAuth)",
                    "limit": { "context": 272000, "output": 128000 },
                    "modalities": { "input": ["text", "image"], "output": ["text"] },
                    "options": {
                      "reasoningEffort": "high",
                      "reasoningSummary": "detailed",
                      "textVerbosity": "medium",
                      "include": ["reasoning.encrypted_content"],
                      "store": false
                    }
                  },
                  "gpt-5.1-codex-low": {
                    "name": "GPT 5.1 Codex Low (OAuth)",
                    "limit": {
                      "context": 272000,
                      "output": 128000
                    },
                    "options": {
                      "reasoningEffort": "low",
                      "reasoningSummary": "auto",
                      "textVerbosity": "medium",
                      "include": [
                        "reasoning.encrypted_content"
                      ],
                      "store": false
                    }
                  },
                  "gpt-5.1-codex-medium": {
                    "name": "GPT 5.1 Codex Medium (OAuth)",
                    "limit": {
                      "context": 272000,
                      "output": 128000
                    },
                    "options": {
                      "reasoningEffort": "medium",
                      "reasoningSummary": "auto",
                      "textVerbosity": "medium",
                      "include": [
                        "reasoning.encrypted_content"
                      ],
                      "store": false
                    }
                  },
                  "gpt-5.1-codex-high": {
                    "name": "GPT 5.1 Codex High (OAuth)",
                    "limit": {
                      "context": 272000,
                      "output": 128000
                    },
                    "options": {
                      "reasoningEffort": "high",
                      "reasoningSummary": "detailed",
                      "textVerbosity": "medium",
                      "include": [
                        "reasoning.encrypted_content"
                      ],
                      "store": false
                    }
                  },
                  "gpt-5.1-codex-mini-medium": {
                    "name": "GPT 5.1 Codex Mini Medium (OAuth)",
                    "limit": {
                      "context": 272000,
                      "output": 128000
                    },
                    "options": {
                      "reasoningEffort": "medium",
                      "reasoningSummary": "auto",
                      "textVerbosity": "medium",
                      "include": [
                        "reasoning.encrypted_content"
                      ],
                      "store": false
                    }
                  },
                  "gpt-5.1-codex-mini-high": {
                    "name": "GPT 5.1 Codex Mini High (OAuth)",
                    "limit": {
                      "context": 272000,
                      "output": 128000
                    },
                    "options": {
                      "reasoningEffort": "high",
                      "reasoningSummary": "detailed",
                      "textVerbosity": "medium",
                      "include": [
                        "reasoning.encrypted_content"
                      ],
                      "store": false
                    }
                  },
                  "gpt-5.1-low": {
                    "name": "GPT 5.1 Low (OAuth)",
                    "limit": {
                      "context": 272000,
                      "output": 128000
                    },
                    "options": {
                      "reasoningEffort": "low",
                      "reasoningSummary": "auto",
                      "textVerbosity": "low",
                      "include": [
                        "reasoning.encrypted_content"
                      ],
                      "store": false
                    }
                  },
                  "gpt-5.1-medium": {
                    "name": "GPT 5.1 Medium (OAuth)",
                    "limit": {
                      "context": 272000,
                      "output": 128000
                    },
                    "options": {
                      "reasoningEffort": "medium",
                      "reasoningSummary": "auto",
                      "textVerbosity": "medium",
                      "include": [
                        "reasoning.encrypted_content"
                      ],
                      "store": false
                    }
                  },
                  "gpt-5.1-high": {
                    "name": "GPT 5.1 High (OAuth)",
                    "limit": {
                      "context": 272000,
                      "output": 128000
                    },
                    "options": {
                      "reasoningEffort": "high",
                      "reasoningSummary": "detailed",
                      "textVerbosity": "high",
                      "include": [
                        "reasoning.encrypted_content"
                      ],
                      "store": false
                    }
                  }
                }
              }
            },
            "mcp": {
              "rime": {
                "type": "local",
                "command": ["${rime}/bin/rime", "stdio"],
                "enabled": true
              }
            }
          }
        '';
    }
  ];
}
