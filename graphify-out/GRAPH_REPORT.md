# Graph Report - .  (2026-06-04)

## Corpus Check
- Corpus is ~3,330 words - fits in a single context window. You may not need a graph.

## Summary
- 39 nodes · 40 edges · 11 communities (3 shown, 8 thin omitted)
- Extraction: 92% EXTRACTED · 8% INFERRED · 0% AMBIGUOUS · INFERRED: 3 edges (avg confidence: 0.82)
- Token cost: 33,000 input · 2,906 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Monitor Pinning & Consistency|Monitor Pinning & Consistency]]
- [[_COMMUNITY_Binding Modes & Navigation|Binding Modes & Navigation]]
- [[_COMMUNITY_Workspace NU App Routing|Workspace N/U App Routing]]
- [[_COMMUNITY_Layout Snapshot Scripts|Layout Snapshot Scripts]]
- [[_COMMUNITY_Claude Code Permissions|Claude Code Permissions]]
- [[_COMMUNITY_Brave Browser Workspace|Brave Browser Workspace]]
- [[_COMMUNITY_WhatsApp Workspace|WhatsApp Workspace]]
- [[_COMMUNITY_Discord Workspace|Discord Workspace]]
- [[_COMMUNITY_apply-monitor-layout Script|apply-monitor-layout Script]]
- [[_COMMUNITY_monitor-setup Script|monitor-setup Script]]
- [[_COMMUNITY_save-monitor-layout Script|save-monitor-layout Script]]

## God Nodes (most connected - your core abstractions)
1. `README.md (human-facing documentation)` - 9 edges
2. `Workspace-to-Monitor Force Assignment (secondary pinning)` - 5 edges
3. `Main Binding Mode` - 4 edges
4. `Service Binding Mode` - 4 edges
5. `Workspace N (Neat/Docker/Wispr)` - 4 edges
6. `Workspace S (Spotify)` - 3 edges
7. `Known Monitor-Script Inconsistencies` - 3 edges
8. `permissions` - 2 edges
9. `Resize Binding Mode` - 2 edges
10. `j/k/i/l Directional Navigation Scheme` - 2 edges

## Surprising Connections (you probably didn't know these)
- `Three-Layer Consistency Constraint` --references--> `README.md (human-facing documentation)`  [EXTRACTED]
  CLAUDE.md → README.md
- `README.md (human-facing documentation)` --references--> `Resize Binding Mode`  [EXTRACTED]
  README.md → aerospace.toml
- `README.md (human-facing documentation)` --references--> `j/k/i/l Directional Navigation Scheme`  [EXTRACTED]
  README.md → aerospace.toml
- `README.md (human-facing documentation)` --references--> `Workspace-to-Monitor Force Assignment (secondary pinning)`  [EXTRACTED]
  README.md → aerospace.toml
- `README.md (human-facing documentation)` --references--> `Main Binding Mode`  [EXTRACTED]
  README.md → aerospace.toml

## Hyperedges (group relationships)
- **Three Layers That Must Stay Consistent** — aerospace_claude_three_layer_consistency, aerospace_readme_doc, aerospace_monitor_setup_script, aerospace_aerospace_monitor_force_assignment [EXTRACTED 1.00]
- **Workspaces Pinned to Secondary Monitor** — aerospace_aerospace_monitor_force_assignment, aerospace_aerospace_workspace_s, aerospace_aerospace_workspace_z [EXTRACTED 1.00]
- **Apps Routed to Workspace N** — aerospace_aerospace_workspace_n, aerospace_aerospace_rule_neat, aerospace_aerospace_rule_docker, aerospace_aerospace_rule_wispr [EXTRACTED 1.00]

## Communities (11 total, 8 thin omitted)

### Community 0 - "Monitor Pinning & Consistency"
Cohesion: 0.32
Nodes (7): Workspace-to-Monitor Force Assignment (secondary pinning), Auto-Assign Spotify Rule, Auto-Assign Zoom Rule, Workspace S (Spotify), Workspace Z (Zoom), Known Monitor-Script Inconsistencies, Three-Layer Consistency Constraint

### Community 1 - "Binding Modes & Navigation"
Cohesion: 0.43
Nodes (7): j/k/i/l Directional Navigation Scheme, alt+shift+jkil Move/Join Overload, Main Binding Mode, Resize Binding Mode, Service Binding Mode, Service Mode Esc Reload-Config, README.md (human-facing documentation)

### Community 2 - "Workspace N/U App Routing"
Cohesion: 0.33
Nodes (6): Auto-Assign Docker Rule, Auto-Assign Figma Rule, Auto-Assign Neat Download Manager Rule, Auto-Assign Wispr Flow Rule, Workspace N (Neat/Docker/Wispr), Workspace U (Figma)

## Knowledge Gaps
- **17 isolated node(s):** `apply-monitor-layout.sh script`, `monitor-setup.sh script`, `save-monitor-layout.sh script`, `allow`, `Workspace W (WhatsApp)` (+12 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **8 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `README.md (human-facing documentation)` connect `Binding Modes & Navigation` to `Monitor Pinning & Consistency`, `Layout Snapshot Scripts`?**
  _High betweenness centrality (0.124) - this node is a cross-community bridge._
- **Why does `Workspace-to-Monitor Force Assignment (secondary pinning)` connect `Monitor Pinning & Consistency` to `Binding Modes & Navigation`?**
  _High betweenness centrality (0.062) - this node is a cross-community bridge._
- **What connects `apply-monitor-layout.sh script`, `monitor-setup.sh script`, `save-monitor-layout.sh script` to the rest of the system?**
  _18 weakly-connected nodes found - possible documentation gaps or missing edges._