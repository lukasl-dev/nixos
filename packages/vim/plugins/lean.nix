{ pkgs, ... }:

let
  package = pkgs.vimUtils.buildVimPlugin {
    name = "lean.nvim";
    pname = "lean.nvim";
    src = pkgs.fetchFromGitHub {
      owner = "Julian";
      repo = "lean.nvim";
      rev = "6839dec855abf562a908abb00654b4a99156315f";
      hash = "sha256-EZ9XBDoiPDwiN6Sm6wLFQlE2GXN6CnqSFiNSq7YqKtc=";
    };
    nvimSkipModules = [
      "proofwidgets.expr_presentation"
      "proofwidgets.make_edit_link"
      "proofwidgets.interactive_expr"
      "proofwidgets.call_cancellable"
      "proofwidgets.present_selection"
      "proofwidgets.html"
      "lean.widget.interactive_goal"
      "lean.widget.interactive_diagnostic"
      "lean.widget.tagged_text"
      "lean.widget.interactive_code"
      "lean.infoview.components"
      "lean.infoview"
      "lean.infoview.plain"
      "lean.rpc"
      "lean.commands"
      "lean.stderr"
      "lean.tui"
      "lean.loogle"
      "lean.widgets"
      "lean.widgets.ConvSelectionPanel"
      "lean.widgets.Mathlib.Tactic.InteractiveUnfold.UnfoldComponent"
      "lean.widgets.ProofStatus"
      "lean.widgets.Verbose.English.suggestionsPanel"
      "lean.widgets.Verbose.French.suggestionsPanel"
      "lean.widgets.ProofWidgets.SelectionPanel"
      "lean.widgets.ProofWidgets.GoalTypePanel"
      "lean.widgets.ProofWidgets.HtmlDisplayPanel"
      "lean.widgets.GoToModuleLink"
      "lean.widgets.Lean.errorDescriptionWidget"
      "lean.widgets.Lean.Meta.Hint.tryThisDiffWidget"
      "lean.widgets.Lean.Meta.Tactic.TryThis.tryThisWidget"
      "lean.widgets.llmstepTryThisWidget"
      "tui.html"
    ];
  };
in
{
  vim = {
    extraPackages = with pkgs; [
      lean4
      elan
    ];

    lazy.plugins."lean.nvim" = {
      inherit package;
      setupModule = "lean";
      setupOpts = {
        mappings = true;
      };
      event = [ "BufReadPre" ];
    };
  };
}
