{ inputs, ... }:

let
  extensions =
    exts:
    builtins.listToAttrs (
      map (extension: {
        name = extension.id;
        value = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/${extension.name}/latest.xpi";
          installation_mode = "force_installed";
        };
      }) exts
    );
in
{
  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  programs.zen-browser = {
    enable = true;
    policies = {
      DisableAppUpdate = true;
      DisableTelemetry = true;
      ExtensionSettings = extensions [
        {
          # SponsorBlock
          id = "sponsorBlocker@ajay.app";
          name = "sponsorblock";
        }
        {
          # Bitwarden
          id = "{446900e4-71c2-419f-a6a7-df9c091e268b}";
          name = "bitwarden-password-manager";
        }
        {
          # DarkReader
          id = "addon@darkreader.org";
          name = "darkreader";
        }
        {
          # Wappalyzer
          id = "wappalyzer@crunchlabz.com";
          name = "wappalyzer";
        }
        {
          # Return YouTube Dislike
          id = "{762f9885-5a13-4abd-9c77-433dcd38b8fd}";
          name = "return-youtube-dislike";
        }
        {
          # LanguageTool
          id = "languagetool-webextension@languagetool.org";
          name = "languagetool";
        }
        {
          # uBlock Origin
          id = "uBlock0@raymondhill.net";
          name = "ublock-origin";
        }
        {
          # # Vimium
          id = "{d7742d87-e61d-4b78-b8a1-b469842139fa}";
          name = "vimium-ff";
        }
        {
          # Watch2Gether
          id = "{6ea0a676-b3ef-48aa-b23d-24c8876945fb}";
          name = "w2g";
        }
        {
          # Atom Material Icons
          id = "{f0503c92-a634-43fd-912d-63c8fde00586}";
          name = "atom_file_icons_web";
        }
        {
          # Tags for Google Calendar
          id = "{5f824c5f-b9c9-4d46-b602-021ea050b850}";
          name = "google_calendar_tags";
        }
        {
          # Minimal Twitter
          id = "{e7476172-097c-4b77-b56e-f56a894adca9}";
          name = "minimaltwitter";
        }
      ];
    };

    profiles.default = {
      isDefault = true;

      settings = {
        "browser.contextual-password-manager.enabled" = false;
        "services.sync.engine.passwords" = false;
        "privacy.cpd.passwords" = false;
        "signon.rememberSignons" = false;
        "signon.autofillForms" = false;
      };
    };
  };
}
